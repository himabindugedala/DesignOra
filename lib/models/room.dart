import 'student.dart';

class Room {
  final String id;
  final String name;
  final String block;
  final String roomNumber;
  final Gender allowedGender;
  final int capacity;
  final List<String> amenities;

  const Room({
    required this.id,
    required this.name,
    required this.block,
    required this.roomNumber,
    required this.allowedGender,
    required this.capacity,
    required this.amenities,
  });

  String get fullLocation => '$block, Room $roomNumber';

  static const Room maleRoom = Room(
    id: 'room_male_102',
    name: 'Male Celebration Room',
    block: 'Block A (Admin Wing)',
    roomNumber: '102',
    allowedGender: Gender.male,
    capacity: 25,
    amenities: [
      'Sound System (Volume Regulated)',
      'Celebration Table & Cake Stand',
      'Air Conditioning',
      'Party LED Ambience',
      'Dustbins & Clean-up Kit',
    ],
  );

  static const Room femaleRoom = Room(
    id: 'room_female_104',
    name: 'Female Celebration Room',
    block: 'Block B (Student Activity Wing)',
    roomNumber: '104',
    allowedGender: Gender.female,
    capacity: 25,
    amenities: [
      'Sound System (Volume Regulated)',
      'Celebration Table & Cake Stand',
      'Air Conditioning',
      'Party LED Ambience',
      'Dustbins & Clean-up Kit',
    ],
  );

  static Room getRoomForGender(Gender gender) {
    return gender == Gender.male ? maleRoom : femaleRoom;
  }
}
