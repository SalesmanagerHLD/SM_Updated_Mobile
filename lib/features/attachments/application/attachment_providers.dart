import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../data/attachment_models.dart';
import '../data/attachment_repository.dart';

final attachmentRepositoryProvider = Provider<AttachmentRepository>(
  (ref) => AttachmentRepository(ref.watch(dioProvider)),
);

final leadAttachmentsProvider = FutureProvider.autoDispose.family<List<LeadAttachmentResponse>, String>((
  ref,
  leadId,
) {
  return ref.watch(attachmentRepositoryProvider).list(leadId);
});
