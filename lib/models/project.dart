import 'package:mongo_dart/mongo_dart.dart' as mongo;

class Project {
  String? id; // MongoDB ObjectId as String
  String name;
  String description;
  String projectType; // 'Website', 'Mobile App', 'Desktop App', 'API', etc.
  DateTime createdAt;
  DateTime? deadline;
  String status; // 'Planning', 'In Progress', 'On Hold', 'Completed'
  int priority; // 1-5, where 5 is highest
  
  // Progress tracking
  int totalFeatures;
  int completedFeatures;
  double progressPercentage;
  
  // Time tracking
  int estimatedHours;
  int actualHours;
  
  // Tech stack
  String techStack; // Comma-separated technologies
  
  // Links
  String? repositoryUrl;
  String? deploymentUrl;
  String? documentationUrl;
  
  // Team
  String assignedTo; // Comma-separated cofounder names
  
  // Visual theme
  String themeColor; // Hex color for project card
  String? iconEmoji; // Optional emoji for project

  Project({
    this.id,
    required this.name,
    required this.description,
    required this.projectType,
    required this.createdAt,
    this.deadline,
    required this.status,
    this.priority = 3,
    this.totalFeatures = 0,
    this.completedFeatures = 0,
    this.progressPercentage = 0.0,
    this.estimatedHours = 0,
    this.actualHours = 0,
    required this.techStack,
    this.repositoryUrl,
    this.deploymentUrl,
    this.documentationUrl,
    required this.assignedTo,
    required this.themeColor,
    this.iconEmoji,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'projectType': projectType,
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'status': status,
      'priority': priority,
      'totalFeatures': totalFeatures,
      'completedFeatures': completedFeatures,
      'progressPercentage': progressPercentage,
      'estimatedHours': estimatedHours,
      'actualHours': actualHours,
      'techStack': techStack,
      'repositoryUrl': repositoryUrl,
      'deploymentUrl': deploymentUrl,
      'documentationUrl': documentationUrl,
      'assignedTo': assignedTo,
      'themeColor': themeColor,
      'iconEmoji': iconEmoji,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    final rawId = map['_id'];
    final parsedId = rawId is String
      ? rawId
      : (rawId is mongo.ObjectId ? rawId.toHexString() : null);
    return Project(
      id: parsedId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      projectType: map['projectType'] ?? 'Other',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      status: map['status'] ?? 'Planning',
      priority: map['priority'] ?? 3,
      totalFeatures: map['totalFeatures'] ?? 0,
      completedFeatures: map['completedFeatures'] ?? 0,
      progressPercentage: (map['progressPercentage'] ?? 0.0).toDouble(),
      estimatedHours: map['estimatedHours'] ?? 0,
      actualHours: map['actualHours'] ?? 0,
      techStack: map['techStack'] ?? '',
      repositoryUrl: map['repositoryUrl'],
      deploymentUrl: map['deploymentUrl'],
      documentationUrl: map['documentationUrl'],
      assignedTo: map['assignedTo'] ?? '',
      themeColor: map['themeColor'] ?? '#00F0FF',
      iconEmoji: map['iconEmoji'],
    );
  }
}

class ProjectFeature {
  String? id;
  String projectId;
  String name;
  String description;
  String status; // 'Todo', 'In Progress', 'Testing', 'Completed', 'Blocked'
  DateTime createdAt;
  DateTime? startedAt;
  DateTime? completedAt;
  int priority; // 1-5
  int estimatedHours;
  int actualHours;
  String assignedTo; // Cofounder name
  String? dependencies; // Comma-separated feature IDs
  String? notes;

  ProjectFeature({
    this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.priority = 3,
    this.estimatedHours = 0,
    this.actualHours = 0,
    required this.assignedTo,
    this.dependencies,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'name': name,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'priority': priority,
      'estimatedHours': estimatedHours,
      'actualHours': actualHours,
      'assignedTo': assignedTo,
      'dependencies': dependencies,
      'notes': notes,
    };
  }

  factory ProjectFeature.fromMap(Map<String, dynamic> map) {
    final rawId = map['_id'];
    final parsedId = rawId is String
      ? rawId
      : (rawId is mongo.ObjectId ? rawId.toHexString() : null);
    return ProjectFeature(
      id: parsedId,
      projectId: map['projectId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Todo',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      startedAt: map['startedAt'] != null ? DateTime.parse(map['startedAt']) : null,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      priority: map['priority'] ?? 3,
      estimatedHours: map['estimatedHours'] ?? 0,
      actualHours: map['actualHours'] ?? 0,
      assignedTo: map['assignedTo'] ?? '',
      dependencies: map['dependencies'],
      notes: map['notes'],
    );
  }
}

class ResearchNote {
  String? id;
  String projectId;
  String title;
  String content;
  String authorName; // Co-founder who added the research
  DateTime createdAt;
  DateTime? updatedAt;
  String category; // 'Technical', 'Market', 'Design', 'User Feedback', 'Other'
  String? tags; // Comma-separated tags
  String? referenceLinks; // Comma-separated URLs

  ResearchNote({
    this.id,
    required this.projectId,
    required this.title,
    required this.content,
    required this.authorName,
    required this.createdAt,
    this.updatedAt,
    this.category = 'Other',
    this.tags,
    this.referenceLinks,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'title': title,
      'content': content,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'category': category,
      'tags': tags,
      'referenceLinks': referenceLinks,
    };
  }

  factory ResearchNote.fromMap(Map<String, dynamic> map) {
    final rawId = map['_id'];
    final parsedId = rawId is String
      ? rawId
      : (rawId is mongo.ObjectId ? rawId.toHexString() : null);
    return ResearchNote(
      id: parsedId,
      projectId: map['projectId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      authorName: map['authorName'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      category: map['category'] ?? 'Other',
      tags: map['tags'],
      referenceLinks: map['referenceLinks'],
    );
  }
}

class ProjectTimeline {
  String? id;
  String projectId;
  String eventType; // 'Created', 'Started', 'Feature Completed', 'Milestone', 'Deployed', 'Updated'
  String title;
  String description;
  DateTime timestamp;
  String performedBy; // Co-founder name
  String? metadata; // JSON string for additional data

  ProjectTimeline({
    this.id,
    required this.projectId,
    required this.eventType,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.performedBy,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'eventType': eventType,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'performedBy': performedBy,
      'metadata': metadata,
    };
  }

  factory ProjectTimeline.fromMap(Map<String, dynamic> map) {
    final rawId = map['_id'];
    final parsedId = rawId is String
      ? rawId
      : (rawId is mongo.ObjectId ? rawId.toHexString() : null);
    return ProjectTimeline(
      id: parsedId,
      projectId: map['projectId'] ?? '',
      eventType: map['eventType'] ?? 'Updated',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      performedBy: map['performedBy'] ?? '',
      metadata: map['metadata'],
    );
  }
}
