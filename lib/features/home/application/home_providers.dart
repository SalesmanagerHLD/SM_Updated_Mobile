import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../leads/application/lead_providers.dart';
import '../../leads/data/lead_models.dart';
import '../../leads/data/lead_repository.dart';
import '../../visits/application/visit_providers.dart';
import '../../visits/data/visit_models.dart';

class HomeAgenda {
  const HomeAgenda({
    required this.todayFollowUps,
    required this.lapsedLeads,
    required this.upcomingFollowUps,
  });

  final List<VisitResponse> todayFollowUps;
  final List<LeadResponse> lapsedLeads;
  final List<VisitResponse> upcomingFollowUps;
}

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// Reproduces the web app's exact 3-call Home composition — there is no
/// single aggregate "dashboard" endpoint server-side (confirmed against the
/// backend), so this is the correct shape, not a simplification:
/// 1. `GET /visits/today` — today-or-earlier PLANNED visits (main agenda)
/// 2. `GET /leads?status=LAPSED` — "Lapsed Calls" section
/// 3. `GET /visits?status=PLANNED&dateFrom=<tomorrow>&dateTo=<+7d>` —
///    "Upcoming Follow-ups" section
final homeAgendaProvider = FutureProvider.autoDispose<HomeAgenda>((ref) async {
  final visitRepository = ref.watch(visitRepositoryProvider);
  final leadRepository = ref.watch(leadRepositoryProvider);

  final today = DateTime.now();
  final tomorrow = today.add(const Duration(days: 1));
  final in7Days = today.add(const Duration(days: 7));

  // Fire all three requests before awaiting any of them, so they run
  // concurrently rather than sequentially.
  final todayFuture = visitRepository.today();
  final lapsedFuture = leadRepository.list(const LeadQuery(status: LeadStatus.lapsed, size: 50));
  final upcomingFuture = visitRepository.list(
    status: VisitStatus.planned,
    dateFrom: _isoDate(tomorrow),
    dateTo: _isoDate(in7Days),
    size: 50,
  );

  final todayVisits = await todayFuture;
  final lapsedPage = await lapsedFuture;
  final upcomingPage = await upcomingFuture;

  return HomeAgenda(
    todayFollowUps: todayVisits,
    lapsedLeads: lapsedPage.content,
    upcomingFollowUps: upcomingPage.content,
  );
});
