enum UserRole {
  citizen,
  official,
  
  // You can add more roles as needed
}

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.citizen:
        return 'Citizen';
      case UserRole.official:
        return 'Official';
    }
  }
  
  String get description {
    switch (this) {
      case UserRole.citizen:
        return 'Report hazards and receive alerts';
      case UserRole.official:
        return 'Manage reports and send alerts';
    }
  }
}