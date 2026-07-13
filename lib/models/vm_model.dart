class VMModel {
  final String id;
  final String name;
  final String os;
  final String osKey;
  final String icon;
  final int storage;      // GB
  final int ram;          // GB
  final String status;    // 'off', 'installing', 'on'
  final DateTime createdAt;
  final String imagePath; // Caminho do disco .qcow2
  final String isoPath;   // Caminho do ISO (se instalando)

  VMModel({
    required this.id,
    required this.name,
    required this.os,
    required this.osKey,
    required this.icon,
    required this.storage,
    required this.ram,
    this.status = 'off',
    required this.createdAt,
    required this.imagePath,
    this.isoPath = '',
  });

  factory VMModel.fromJson(Map<String, dynamic> json) {
    return VMModel(
      id: json['id'],
      name: json['name'],
      os: json['os'],
      osKey: json['osKey'],
      icon: json['icon'],
      storage: json['storage'],
      ram: json['ram'],
      status: json['status'] ?? 'off',
      createdAt: DateTime.parse(json['createdAt']),
      imagePath: json['imagePath'],
      isoPath: json['isoPath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'os': os,
      'osKey': osKey,
      'icon': icon,
      'storage': storage,
      'ram': ram,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
      'isoPath': isoPath,
    };
  }

  VMModel copyWith({
    String? id,
    String? name,
    String? os,
    String? osKey,
    String? icon,
    int? storage,
    int? ram,
    String? status,
    DateTime? createdAt,
    String? imagePath,
    String? isoPath,
  }) {
    return VMModel(
      id: id ?? this.id,
      name: name ?? this.name,
      os: os ?? this.os,
      osKey: osKey ?? this.osKey,
      icon: icon ?? this.icon,
      storage: storage ?? this.storage,
      ram: ram ?? this.ram,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
      isoPath: isoPath ?? this.isoPath,
    );
  }
}
