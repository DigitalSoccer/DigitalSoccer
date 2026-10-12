import '../models/match.dart';

final matchDays = [
  // ================= SÁBADO =================
  MatchDay(
    day: 'Sábado',
    fields: [
      FieldSchedule(
        fieldName: 'Cancha Mario Osben',
        matches: [
          Match(time: '12:30', home: 'El Valle', homeId: 'el-valle', away: 'Jackson', awayId: 'jackson', category: '1° Infantil'),
          Match(time: '13:30', home: 'El Valle', homeId: 'el-valle', away: 'Jackson', awayId: 'jackson', category: '2° Infantil'),
        ],
      ),

      FieldSchedule(
        fieldName: 'Cancha Chiguayante Sur',
        matches: [
          Match(time: '11:30', home: 'Ferrobadminton', homeId: 'ferrobadminton', away: 'Maestranza', awayId: 'maestranza', category: 'Juvenil'),
          Match(time: '13:00', home: 'San Pablo', homeId: 'san-pablo', away: 'U.L. Carrera', awayId: 'ul-carrera', category: '2° Infantil'),
          Match(time: '14:00', home: 'San Pablo', homeId: 'san-pablo', away: 'U.L. Carrera', awayId: 'ul-carrera', category: '1° Infantil'),
          Match(time: '16:40', home: 'San Pablo', homeId: 'san-pablo', away: 'U.L. Carrera', awayId: 'ul-carrera', category: 'H. Ortiz'),
          Match(time: '19:10', home: 'Ferrobadminton', homeId: 'ferrobadminton', away: 'Maestranza', awayId: 'maestranza', category: 'Senior'),
        ],
      ),

      FieldSchedule(
        fieldName: 'Cancha Independiente',
        matches: [
          Match(time: '10:00', home: 'Schaub F.C', homeId: 'schaub-fc', away: 'Union Angamos', awayId: 'union-angamos', category: '2° Infantil'),
          Match(time: '11:00', home: 'Schaub F.C', homeId: 'schaub-fc', away: 'Union Angamos', awayId: 'union-angamos', category: '1° Infantil'),
          Match(time: '13:30', home: 'Chiguayante Sur', homeId: 'chiguayante-sur', away: 'U.L Bolzhauser', awayId: 'ul-bolzhauser', category: '2° Infantil'),
          Match(time: '15:00', home: 'Chiguayante Sur', homeId: 'chiguayante-sur', away: 'U.L Bolzhauser', awayId: 'ul-bolzhauser', category: '1° Infantil'),
          Match(time: '17:00', home: 'Chiguayante Sur', homeId: 'chiguayante-sur', away: 'U.L Bolzhauser', awayId: 'ul-bolzhauser', category: 'Senior'),
        ],
      ),

      FieldSchedule(
        fieldName: 'Cancha José Vilches',
        matches: [
          Match(time: '12:00', home: 'Bdo. O’Higgins', homeId: 'bdo-ohiggins', away: 'Arturo Prat', awayId: 'arturo-prat', category: '2° Infantil'),
          Match(time: '13:00', home: 'Bdo. O’Higgins', homeId: 'bdo-ohiggins', away: 'Arturo Prat', awayId: 'arturo-prat', category: '1° Infantil'),
        ],
      ),

      FieldSchedule(
        fieldName: 'Cancha Magallanes',
        matches: [
          Match(time: '10:00', home: 'Nacional', homeId: 'nacional', away: 'Leinenweber', awayId: 'leinenweber', category: '2° Infantil'),
          Match(time: '11:00', home: 'Nacional', homeId: 'nacional', away: 'Leinenweber', awayId: 'leinenweber', category: '1° Infantil'),
          Match(time: '13:30', home: 'El Tigre', homeId: 'el-tigre', away: 'Magallanes', awayId: 'magallanes', category: '2° Infantil'),
          Match(time: '15:00', home: 'El Tigre', homeId: 'el-tigre', away: 'Magallanes', awayId: 'magallanes', category: '1° Infantil'),
          Match(time: '17:00', home: 'El Tigre', homeId: 'el-tigre', away: 'Magallanes', awayId: 'magallanes', category: 'H. Ortiz'),
          Match(time: '19:20', home: 'Nacional', homeId: 'nacional', away: 'Leinenweber', awayId: 'leinenweber', category: 'Senior'),
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
          Match(time: '09:00', home: 'El Valle', homeId: 'el-valle', away: 'Jackson', awayId: 'jackson', category: 'Segunda'),
          Match(time: '10:30', home: 'El Valle', homeId: 'el-valle', away: 'Jackson', awayId: 'jackson', category: 'Primera'),
          Match(time: '12:00', home: 'El Valle', homeId: 'el-valle', away: 'Jackson', awayId: 'jackson', category: 'Senior'),
          Match(time: '15:00', home: 'Union Angamos', homeId: 'union-angamos', away: 'Bdo. O’Higgins', awayId: 'bdo-ohiggins', category: 'Honor'),
          Match(time: '18:00', home: 'Ferrobadminton', homeId: 'ferrobadminton', away: 'Chiguayante Sur', awayId: 'chiguayante-sur', category: 'Honor'),
        ],
      ),

      FieldSchedule(
        fieldName: 'Cancha Chiguayante Sur',
        matches: [
          Match(time: '09:00', home: 'Ferrobadminton', homeId: 'ferrobadminton', away: 'Maestranza', awayId: 'maestranza', category: 'Segunda'),
          Match(time: '10:30', home: 'Ferrobadminton', homeId: 'ferrobadminton', away: 'Maestranza', awayId: 'maestranza', category: 'Primera'),
          Match(time: '12:00', home: 'San Pablo', homeId: 'san-pablo', away: 'U.L. Carrera', awayId: 'ul-carrera', category: 'Segunda'),
          Match(time: '13:30', home: 'San Pablo', homeId: 'san-pablo', away: 'U.L. Carrera', awayId: 'ul-carrera', category: 'Primera'),
          Match(time: '14:50', home: 'San Pablo', homeId: 'san-pablo', away: 'U.L. Carrera', awayId: 'ul-carrera', category: 'Senior'),
          Match(time: '16:30', home: 'San Pablo', homeId: 'san-pablo', away: 'Nacional', awayId: 'nacional', category: 'Honor'),
          Match(time: '18:30', home: 'Arturo Prat', homeId: 'arturo-prat', away: 'Maestranza', awayId: 'maestranza', category: 'Honor'),
        ],
      ),

      FieldSchedule(
        fieldName: 'Cancha Independiente',
        matches: [
          Match(time: '09:00', home: 'Schaub F.C', homeId: 'schaub-fc', away: 'Union Angamos', awayId: 'union-angamos', category: 'Segunda'),
          Match(time: '10:30', home: 'Schaub F.C', homeId: 'schaub-fc', away: 'Union Angamos', awayId: 'union-angamos', category: 'Primera'),
          Match(time: '13:30', home: 'Chiguayante Sur', homeId: 'chiguayante-sur', away: 'U.L Bolzhauser', awayId: 'ul-bolzhauser', category: 'Segunda'),
          Match(time: '15:00', home: 'Chiguayante Sur', homeId: 'chiguayante-sur', away: 'U.L Bolzhauser', awayId: 'ul-bolzhauser', category: 'Primera'),
        ],
      ),

      FieldSchedule(
        fieldName: 'Cancha José Vilches',
        matches: [
          Match(time: '09:00', home: 'Bdo. O’Higgins', homeId: 'bdo-ohiggins', away: 'Arturo Prat', awayId: 'arturo-prat', category: 'Segunda'),
          Match(time: '10:30', home: 'Bdo. O’Higgins', homeId: 'bdo-ohiggins', away: 'Arturo Prat', awayId: 'arturo-prat', category: 'Primera'),
        ],
      ),

      FieldSchedule(
        fieldName: 'Cancha Magallanes',
        matches: [
          Match(time: '09:00', home: 'Nacional', homeId: 'nacional', away: 'Leinenweber', awayId: 'leinenweber', category: 'Segunda'),
          Match(time: '10:30', home: 'Nacional', homeId: 'nacional', away: 'Leinenweber', awayId: 'leinenweber', category: 'Primera'),
          Match(time: '13:30', home: 'El Tigre', homeId: 'el-tigre', away: 'Magallanes', awayId: 'magallanes', category: 'Segunda'),
          Match(time: '14:50', home: 'El Tigre', homeId: 'el-tigre', away: 'Magallanes', awayId: 'magallanes', category: 'Primera'),
          Match(time: '16:20', home: 'El Tigre', homeId: 'el-tigre', away: 'Magallanes', awayId: 'magallanes', category: 'Senior'),
          Match(time: '18:00', home: 'Jackson', homeId: 'jackson', away: 'Magallanes', awayId: 'magallanes', category: 'Honor'),
        ],
      ),
    ],
  ),
];