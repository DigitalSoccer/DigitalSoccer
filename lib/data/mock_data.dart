import '../models/match.dart';

final matchDays = [
  // ================= SÁBADO =================
  MatchDay(
    day: 'Sábado',
    fields: [
      FieldSchedule(
        fieldName: 'Cancha Mario Osben',
        matches: [
          Match(time: '12:30', home: 'El Valle', away: 'Jackson', category: '1° Infantil'),
          Match(time: '13:30', home: 'El Valle', away: 'Jackson', category: '2° Infantil'),
        ],
      ),

      FieldSchedule(
        fieldName: 'Cancha Chiguayante Sur',
        matches: [
          Match(time: '11:30', home: 'Ferrobadminton', away: 'Maestranza', category: 'Juvenil'),
          Match(time: '13:00', home: 'San Pablo', away: 'U.L. Carrera', category: '2° Infantil'),
          Match(time: '14:00', home: 'San Pablo', away: 'U.L. Carrera', category: '1° Infantil'),
          Match(time: '16:40', home: 'San Pablo', away: 'U.L. Carrera', category: 'H. Ortiz'),
          Match(time: '19:10', home: 'Ferrobadminton', away: 'Maestranza', category: 'Senior'),
        ],
      ),

      FieldSchedule(
        fieldName: 'Cancha Independiente',
        matches: [
          Match(time: '10:00', home: 'Schaub F.C', away: 'Union Angamos', category: '2° Infantil'),
          Match(time: '11:00', home: 'Schaub F.C', away: 'Union Angamos', category: '1° Infantil'),
          Match(time: '13:30', home: 'Chiguayante Sur', away: 'U.L Bolzhauser', category: '2° Infantil'),
          Match(time: '15:00', home: 'Chiguayante Sur', away: 'U.L Bolzhauser', category: '1° Infantil'),
          Match(time: '17:00', home: 'Chiguayante Sur', away: 'U.L Bolzhauser', category: 'Senior'),
        ],
      ),

      FieldSchedule(
        fieldName: 'Cancha José Vilches',
        matches: [
          Match(time: '12:00', home: 'Bdo. O’Higgins', away: 'Arturo Prat', category: '2° Infantil'),
          Match(time: '13:00', home: 'Bdo. O’Higgins', away: 'Arturo Prat', category: '1° Infantil'),
        ],
      ),

      FieldSchedule(
        fieldName: 'Cancha Magallanes',
        matches: [
          Match(time: '10:00', home: 'Nacional', away: 'Leinenweber', category: '2° Infantil'),
          Match(time: '11:00', home: 'Nacional', away: 'Leinenweber', category: '1° Infantil'),
          Match(time: '13:30', home: 'El Tigre', away: 'Magallanes', category: '2° Infantil'),
          Match(time: '15:00', home: 'El Tigre', away: 'Magallanes', category: '1° Infantil'),
          Match(time: '17:00', home: 'El Tigre', away: 'Magallanes', category: 'H. Ortiz'),
          Match(time: '19:20', home: 'Nacional', away: 'Leinenweber', category: 'Senior'),
        ],
      ),
    ],
  ),

  // ================= DOMINGO =================
  MatchDay(
    day: 'Domingo',
    fields: [
      FieldSchedule(
        fieldName: 'Cancha Mario Osben',
        matches: [
          Match(time: '09:00', home: 'El Valle', away: 'Jackson', category: 'Segunda'),
          Match(time: '10:30', home: 'El Valle', away: 'Jackson', category: 'Primera'),
          Match(time: '12:00', home: 'El Valle', away: 'Jackson', category: 'Senior'),
          Match(time: '15:00', home: 'Union Angamos', away: 'Bdo. O’Higgins', category: 'Honor'),
          Match(time: '18:00', home: 'Ferrobadminton', away: 'Chiguayante Sur', category: 'Honor'),
        ],
      ),

      FieldSchedule(
        fieldName: 'Cancha Chiguayante Sur',
        matches: [
          Match(time: '09:00', home: 'Ferrobadminton', away: 'Maestranza', category: 'Segunda'),
          Match(time: '10:30', home: 'Ferrobadminton', away: 'Maestranza', category: 'Primera'),
          Match(time: '12:00', home: 'San Pablo', away: 'U.L. Carrera', category: 'Segunda'),
          Match(time: '13:30', home: 'San Pablo', away: 'U.L. Carrera', category: 'Primera'),
          Match(time: '14:50', home: 'San Pablo', away: 'U.L. Carrera', category: 'Senior'),
          Match(time: '16:30', home: 'San Pablo', away: 'Nacional', category: 'Honor'),
          Match(time: '18:30', home: 'Arturo Prat', away: 'Maestranza', category: 'Honor'),
        ],
      ),

      FieldSchedule(
        fieldName: 'Cancha Independiente',
        matches: [
          Match(time: '09:00', home: 'Schaub F.C', away: 'Union Angamos', category: 'Segunda'),
          Match(time: '10:30', home: 'Schaub F.C', away: 'Union Angamos', category: 'Primera'),
          Match(time: '13:30', home: 'Chiguayante Sur', away: 'U.L Bolzhauser', category: 'Segunda'),
          Match(time: '15:00', home: 'Chiguayante Sur', away: 'U.L Bolzhauser', category: 'Primera'),
        ],
      ),

      FieldSchedule(
        fieldName: 'Cancha José Vilches',
        matches: [
          Match(time: '09:00', home: 'Bdo. O’Higgins', away: 'Arturo Prat', category: 'Segunda'),
          Match(time: '10:30', home: 'Bdo. O’Higgins', away: 'Arturo Prat', category: 'Primera'),
        ],
      ),

      FieldSchedule(
        fieldName: 'Cancha Magallanes',
        matches: [
          Match(time: '09:00', home: 'Nacional', away: 'Leinenweber', category: 'Segunda'),
          Match(time: '10:30', home: 'Nacional', away: 'Leinenweber', category: 'Primera'),
          Match(time: '13:30', home: 'El Tigre', away: 'Magallanes', category: 'Segunda'),
          Match(time: '14:50', home: 'El Tigre', away: 'Magallanes', category: 'Primera'),
          Match(time: '16:20', home: 'El Tigre', away: 'Magallanes', category: 'Senior'),
          Match(time: '18:00', home: 'Jackson', away: 'Magallanes', category: 'Honor'),
        ],
      ),
    ],
  ),
];