import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../models/project.dart';
import '../database/mongodb_helper.dart';
import '../services/notification_helper.dart';

class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  List<ProjectFeature> _features = [];
  List<ResearchNote> _researchNotes = [];
  List<ProjectTimeline> _timeline = [];
  
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => _projects;
  List<ProjectFeature> get features => _features;
  List<ResearchNote> get researchNotes => _researchNotes;
  List<ProjectTimeline> get timeline => _timeline;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Overall research (not tied to a specific project)
  List<ResearchNote> get overallResearch => _researchNotes
      .where((r) => r.projectId == 'overall')
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // Get features for a specific project
  List<ProjectFeature> getFeaturesForProject(String projectId) {
    return _features.where((f) => f.projectId == projectId).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  // Get research notes for a specific project
  List<ResearchNote> getResearchForProject(String projectId) {
    return _researchNotes.where((r) => r.projectId == projectId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get timeline for a specific project
  List<ProjectTimeline> getTimelineForProject(String projectId) {
    return _timeline.where((t) => t.projectId == projectId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get project statistics
  Map<String, dynamic> getProjectStats(String projectId) {
    final project = _projects.firstWhere((p) => p.id == projectId);
    final projectFeatures = getFeaturesForProject(projectId);
    
    final completedFeatures = projectFeatures.where((f) => f.status == 'Completed').length;
    final inProgressFeatures = projectFeatures.where((f) => f.status == 'In Progress').length;
    final blockedFeatures = projectFeatures.where((f) => f.status == 'Blocked').length;
    
    return {
      'totalFeatures': projectFeatures.length,
      'completedFeatures': completedFeatures,
      'inProgressFeatures': inProgressFeatures,
      'blockedFeatures': blockedFeatures,
      'progressPercentage': projectFeatures.isEmpty 
          ? 0.0 
          : (completedFeatures / projectFeatures.length) * 100,
      'estimatedHours': project.estimatedHours,
      'actualHours': project.actualHours,
    };
  }

  // Get overall statistics
  Map<String, dynamic> getOverallStats() {
    final totalProjects = _projects.length;
    final activeProjects = _projects.where((p) => p.status == 'In Progress').length;
    final completedProjects = _projects.where((p) => p.status == 'Completed').length;
    final totalFeatures = _features.length;
    final completedFeatures = _features.where((f) => f.status == 'Completed').length;
    
    return {
      'totalProjects': totalProjects,
      'activeProjects': activeProjects,
      'completedProjects': completedProjects,
      'onHoldProjects': _projects.where((p) => p.status == 'On Hold').length,
      'totalFeatures': totalFeatures,
      'completedFeatures': completedFeatures,
      'progressPercentage': totalFeatures == 0 
          ? 0.0 
          : (completedFeatures / totalFeatures) * 100,
    };
  }

  // Load all data
  Future<void> loadAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await MongoDBHelper.instance.database;
      
      // Load projects
      final projectsCollection = db.collection(MongoDBHelper.projectsCollectionName);
      final projectsData = await projectsCollection.find().toList();
      _projects = projectsData.map((data) => Project.fromMap(data)).toList();
      
      // Load features
      final featuresCollection = db.collection(MongoDBHelper.projectFeaturesCollectionName);
      final featuresData = await featuresCollection.find().toList();
      _features = featuresData.map((data) => ProjectFeature.fromMap(data)).toList();
      
      // Recalculate progress for all projects
      for (var project in _projects) {
        final projectFeatures = _features.where((f) => f.projectId == project.id).toList();
        project.totalFeatures = projectFeatures.length;
        project.completedFeatures = projectFeatures.where((f) => f.status == 'Completed').length;
        project.progressPercentage = project.totalFeatures > 0 
            ? (project.completedFeatures / project.totalFeatures) * 100 
            : 0.0;
      }
      
      // Load research notes
      final researchCollection = db.collection(MongoDBHelper.researchNotesCollectionName);
      final researchData = await researchCollection.find().toList();
      _researchNotes = researchData.map((data) => ResearchNote.fromMap(data)).toList();
      
      // Load timeline
      final timelineCollection = db.collection(MongoDBHelper.projectTimelineCollectionName);
      final timelineData = await timelineCollection.find().toList();
      _timeline = timelineData.map((data) => ProjectTimeline.fromMap(data)).toList();
      
      print('✅ Loaded ${_projects.length} projects, ${_features.length} features, ${_researchNotes.length} research notes');
    } catch (e) {
      _error = e.toString();
      print('❌ Error loading project data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add Project
  Future<void> addProject(Project project) async {
    try {
      final db = await MongoDBHelper.instance.database;
      final collection = db.collection(MongoDBHelper.projectsCollectionName);
      
      final result = await collection.insertOne(project.toMap());
      project.id = (result.id as mongo.ObjectId).toHexString();
      
      _projects.add(project);
      
      // Add timeline entry
      await addTimelineEvent(
        projectId: project.id!,
        eventType: 'Created',
        title: 'Project Created',
        description: 'Project "${project.name}" was created',
        performedBy: project.assignedTo.split(',').first.trim(),
      );
      
      notifyListeners();
    } catch (e) {
      print('❌ Error adding project: $e');
      rethrow;
    }
  }

  // Update Project
  Future<void> updateProject(Project project) async {
    try {
      final db = await MongoDBHelper.instance.database;
      final collection = db.collection(MongoDBHelper.projectsCollectionName);
      
      await collection.updateOne(
        {'_id': _toObjectId(project.id)},
        {'\$set': project.toMap()},
      );
      
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Error updating project: $e');
      rethrow;
    }
  }

  // Delete Project
  Future<void> deleteProject(String projectId) async {
    try {
      final db = await MongoDBHelper.instance.database;
      
      // Delete project
      await db.collection(MongoDBHelper.projectsCollectionName).deleteOne({'_id': _toObjectId(projectId)});
      
      // Delete related features
      await db.collection(MongoDBHelper.projectFeaturesCollectionName).deleteMany({'projectId': projectId});
      
      // Delete related research
      await db.collection(MongoDBHelper.researchNotesCollectionName).deleteMany({'projectId': projectId});
      
      // Delete related timeline
      await db.collection(MongoDBHelper.projectTimelineCollectionName).deleteMany({'projectId': projectId});
      
      _projects.removeWhere((p) => p.id == projectId);
      _features.removeWhere((f) => f.projectId == projectId);
      _researchNotes.removeWhere((r) => r.projectId == projectId);
      _timeline.removeWhere((t) => t.projectId == projectId);
      
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting project: $e');
      rethrow;
    }
  }

  // Add Feature
  Future<void> addFeature(ProjectFeature feature) async {
    try {
      final db = await MongoDBHelper.instance.database;
      final collection = db.collection(MongoDBHelper.projectFeaturesCollectionName);
      
      final result = await collection.insertOne(feature.toMap());
      feature.id = (result.id as mongo.ObjectId).toHexString();
      
      _features.insert(0, feature);
      
      // Update project feature count
      final project = _projects.firstWhere((p) => p.id == feature.projectId);
      project.totalFeatures++;
      if (feature.status == 'Completed') {
        project.completedFeatures++;
      }
      if (project.totalFeatures > 0) {
        project.progressPercentage = (project.completedFeatures / project.totalFeatures) * 100;
      }
      await updateProject(project);
      
      notifyListeners();
    } catch (e) {
      print('❌ Error adding feature: $e');
      rethrow;
    }
  }

  // Update Feature
  Future<void> updateFeature(ProjectFeature feature) async {
    try {
      final db = await MongoDBHelper.instance.database;
      final collection = db.collection(MongoDBHelper.projectFeaturesCollectionName);
      
      final oldFeature = _features.firstWhere((f) => f.id == feature.id);
      final wasCompleted = oldFeature.status == 'Completed';
      final isNowCompleted = feature.status == 'Completed';
      
      await collection.updateOne(
        {'_id': _toObjectId(feature.id)},
        {'\$set': feature.toMap()},
      );
      
      final index = _features.indexWhere((f) => f.id == feature.id);
      if (index != -1) {
        _features[index] = feature;
      }
      
      // Update project completion count
      final project = _projects.firstWhere((p) => p.id == feature.projectId);
      
      if (!wasCompleted && isNowCompleted) {
        // Feature marked as completed
        project.completedFeatures++;
        
        // Add timeline entry
        await addTimelineEvent(
          projectId: feature.projectId,
          eventType: 'Feature Completed',
          title: 'Feature Completed',
          description: 'Feature "${feature.name}" was completed',
          performedBy: feature.assignedTo,
        );
        
        // Send notification for feature completion
        await NotificationHelper().sendToAllDevices(
          title: '✅ Feature Completed',
          body: '"${feature.name}" completed in "${project.name}" by ${feature.assignedTo}',
          data: {
            'type': 'feature_completed',
            'projectId': feature.projectId,
            'featureId': feature.id,
            'featureName': feature.name,
            'completedBy': feature.assignedTo,
          },
        );
      } else if (wasCompleted && !isNowCompleted) {
        // Feature was completed but now changed to another status
        project.completedFeatures--;
      }
      
      // Recalculate progress
      project.progressPercentage = project.totalFeatures > 0
          ? (project.completedFeatures / project.totalFeatures) * 100
          : 0.0;
      await updateProject(project);
      
      notifyListeners();
    } catch (e) {
      print('❌ Error updating feature: $e');
      rethrow;
    }
  }

  // Delete Feature
  Future<void> deleteFeature(String featureId) async {
    try {
      final db = await MongoDBHelper.instance.database;
      final feature = _features.firstWhere((f) => f.id == featureId);
      
      await db.collection(MongoDBHelper.projectFeaturesCollectionName).deleteOne({'_id': _toObjectId(featureId)});
      
      // Update project feature count
      final project = _projects.firstWhere((p) => p.id == feature.projectId);
      project.totalFeatures--;
      if (feature.status == 'Completed') {
        project.completedFeatures--;
      }
      if (project.totalFeatures > 0) {
        project.progressPercentage = (project.completedFeatures / project.totalFeatures) * 100;
      } else {
        project.progressPercentage = 0;
      }
      await updateProject(project);
      
      _features.removeWhere((f) => f.id == featureId);
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting feature: $e');
      rethrow;
    }
  }

  // Add Research Note
  Future<void> addResearchNote(ResearchNote note) async {
    try {
      final db = await MongoDBHelper.instance.database;
      final collection = db.collection(MongoDBHelper.researchNotesCollectionName);

      // Always stamp createdAt on insert
      note.createdAt = DateTime.now();
      
      final result = await collection.insertOne(note.toMap());
      note.id = (result.id as mongo.ObjectId).toHexString();
      
      _researchNotes.add(note);
      
      // Determine if it's overall or project-specific research
      final isOverallResearch = note.projectId == 'overall';
      
      // Add timeline entry
      await addTimelineEvent(
        projectId: note.projectId,
        eventType: 'Updated',
        title: 'Research Added',
        description: '${note.authorName} added research: "${note.title}"',
        performedBy: note.authorName,
      );
      
      // Send notification
      if (isOverallResearch) {
        // Overall research notification
        await NotificationHelper().sendToAllDevices(
          title: '🔬 New Overall Research',
          body: '${note.authorName} added: "${note.title}"',
          data: {
            'type': 'overall_research',
            'researchId': note.id ?? '',
            'authorName': note.authorName,
          },
        );
      } else {
        // Project-specific research notification
        final project = _projects.firstWhere(
          (p) => p.id == note.projectId,
          orElse: () => Project(
            name: 'Unknown Project',
            description: '',
            projectType: '',
            createdAt: DateTime.now(),
            status: '',
            techStack: '',
            assignedTo: '',
            themeColor: '#00F0FF',
          ),
        );
        
        await NotificationHelper().sendToAllDevices(
          title: '📝 New Project Research',
          body: '${note.authorName} added research for "${project.name}": "${note.title}"',
          data: {
            'type': 'project_research',
            'projectId': note.projectId,
            'researchId': note.id ?? '',
            'authorName': note.authorName,
          },
        );
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Error adding research note: $e');
      rethrow;
    }
  }

  Future<void> addOverallResearch(ResearchNote note) async {
    // Force projectId to overall bucket
    note.projectId = 'overall';
    return addResearchNote(note);
  }

  // Update Research Note
  Future<void> updateResearchNote(ResearchNote note) async {
    try {
      final db = await MongoDBHelper.instance.database;
      final collection = db.collection(MongoDBHelper.researchNotesCollectionName);
      
      note.updatedAt = DateTime.now();
      
      await collection.updateOne(
        {'_id': _toObjectId(note.id)},
        {'\$set': note.toMap()},
      );
      
      final index = _researchNotes.indexWhere((r) => r.id == note.id);
      if (index != -1) {
        _researchNotes[index] = note;
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Error updating research note: $e');
      rethrow;
    }
  }

  // Delete Research Note
  Future<void> deleteResearchNote(String noteId) async {
    try {
      final db = await MongoDBHelper.instance.database;
      await db.collection(MongoDBHelper.researchNotesCollectionName).deleteOne({'_id': _toObjectId(noteId)});
      
      _researchNotes.removeWhere((r) => r.id == noteId);
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting research note: $e');
      rethrow;
    }
  }

  // Add Timeline Event
  Future<void> addTimelineEvent({
    required String projectId,
    required String eventType,
    required String title,
    required String description,
    required String performedBy,
    String? metadata,
  }) async {
    try {
      final db = await MongoDBHelper.instance.database;
      final collection = db.collection(MongoDBHelper.projectTimelineCollectionName);
      
      final event = ProjectTimeline(
        projectId: projectId,
        eventType: eventType,
        title: title,
        description: description,
        timestamp: DateTime.now(),
        performedBy: performedBy,
        metadata: metadata,
      );
      
      final result = await collection.insertOne(event.toMap());
      event.id = (result.id as mongo.ObjectId).toHexString();
      
      _timeline.add(event);
      notifyListeners();
    } catch (e) {
      print('❌ Error adding timeline event: $e');
      // Don't rethrow - timeline is not critical
    }
  }

  mongo.ObjectId _toObjectId(String? id) {
    if (id == null) return mongo.ObjectId();
    try {
      return mongo.ObjectId.fromHexString(id);
    } catch (_) {
      return mongo.ObjectId();
    }
  }
}
