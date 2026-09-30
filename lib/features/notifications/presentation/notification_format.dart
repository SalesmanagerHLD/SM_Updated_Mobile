import '../data/notification_models.dart';

/// Renders title/description/tap-target from a notification's `type` +
/// `payload`, using the exact payload keys each backend write site puts in
/// (grounded directly against `LeadService#buildReassignmentPayload`,
/// `MissedVisitJob#buildPayload`, `LapsedLeadJob#buildPayload`/
/// `buildDigestPayload`, `LeaveRequestService#buildPayload`) rather than
/// guessed field names.
class NotificationFormat {
  NotificationFormat._();

  static String title(NotificationResponse notification) => switch (notification.type) {
    NotificationType.leadReassigned => 'Lead reassigned to you',
    NotificationType.visitMissed => 'Visit missed',
    NotificationType.leadLapsed => 'Lead lapsed',
    NotificationType.leadLapsedDigest => 'Leads lapsed',
    NotificationType.leaveRequestSubmitted => 'Leave request submitted',
    NotificationType.leaveRequestApproved => 'Leave request approved',
    NotificationType.leaveRequestRejected => 'Leave request rejected',
    NotificationType.lowStock => 'Low stock',
    _ => 'Notification',
  };

  static String description(NotificationResponse notification) {
    final payload = notification.payload;
    return switch (notification.type) {
      NotificationType.leadReassigned => [
        payload['companyName'],
        if (payload['reassignedByName'] != null) 'from ${payload['reassignedByName']}',
      ].where((e) => e != null).join(' — '),
      NotificationType.visitMissed => [
        if (payload['companyName'] != null) "Planned visit for '${payload['companyName']}'",
        if (payload['visitDate'] != null) 'on ${payload['visitDate']}',
        if (payload['employeeName'] != null) 'by ${payload['employeeName']}',
      ].join(' '),
      NotificationType.leadLapsed => payload['companyName'] != null
          ? '${payload['companyName']} had no activity for a while'
          : 'A lead had no activity for a while',
      NotificationType.leadLapsedDigest => '${payload['count'] ?? 'Several'} leads lapsed overnight',
      NotificationType.leaveRequestSubmitted ||
      NotificationType.leaveRequestApproved ||
      NotificationType.leaveRequestRejected => [
        payload['employeeName'],
        payload['leaveTypeName'],
        if (payload['startDate'] != null && payload['endDate'] != null)
          '${payload['startDate']} – ${payload['endDate']}',
      ].where((e) => e != null).join(' · '),
      _ => '',
    };
  }

  /// Where tapping this notification should navigate, if anywhere.
  static String? targetRoute(NotificationResponse notification) =>
      targetRouteFor(notification.type, notification.payload);

  /// Same logic as [targetRoute], taking `type`/`payload` directly so
  /// `PushService`'s tap handler (working off a raw FCM data payload, not
  /// a fetched `NotificationResponse`) can share it instead of duplicating
  /// the type→route mapping.
  static String? targetRouteFor(String type, Map<String, dynamic> payload) {
    return switch (type) {
      NotificationType.leadReassigned ||
      NotificationType.leadLapsed ||
      NotificationType.visitMissed => payload['leadId'] != null ? '/leads/${payload['leadId']}' : null,
      NotificationType.leadLapsedDigest => '/leads',
      NotificationType.leaveRequestSubmitted ||
      NotificationType.leaveRequestApproved ||
      NotificationType.leaveRequestRejected => '/leave',
      _ => null,
    };
  }
}
