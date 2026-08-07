// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LeadsCacheTable extends LeadsCache
    with TableInfo<$LeadsCacheTable, LeadsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeadsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyNameMeta = const VerificationMeta(
    'companyName',
  );
  @override
  late final GeneratedColumn<String> companyName = GeneratedColumn<String>(
    'company_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactPersonMeta = const VerificationMeta(
    'contactPerson',
  );
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
    'contact_person',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactNoMeta = const VerificationMeta(
    'contactNo',
  );
  @override
  late final GeneratedColumn<String> contactNo = GeneratedColumn<String>(
    'contact_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _interestLevelIdMeta = const VerificationMeta(
    'interestLevelId',
  );
  @override
  late final GeneratedColumn<String> interestLevelId = GeneratedColumn<String>(
    'interest_level_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextFollowupDateMeta = const VerificationMeta(
    'nextFollowupDate',
  );
  @override
  late final GeneratedColumn<String> nextFollowupDate = GeneratedColumn<String>(
    'next_followup_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawMeta = const VerificationMeta('raw');
  @override
  late final GeneratedColumn<String> raw = GeneratedColumn<String>(
    'raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyName,
    contactPerson,
    contactNo,
    status,
    interestLevelId,
    nextFollowupDate,
    raw,
    syncState,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leads_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeadsCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_name')) {
      context.handle(
        _companyNameMeta,
        companyName.isAcceptableOrUnknown(
          data['company_name']!,
          _companyNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companyNameMeta);
    }
    if (data.containsKey('contact_person')) {
      context.handle(
        _contactPersonMeta,
        contactPerson.isAcceptableOrUnknown(
          data['contact_person']!,
          _contactPersonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contactPersonMeta);
    }
    if (data.containsKey('contact_no')) {
      context.handle(
        _contactNoMeta,
        contactNo.isAcceptableOrUnknown(data['contact_no']!, _contactNoMeta),
      );
    } else if (isInserting) {
      context.missing(_contactNoMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('interest_level_id')) {
      context.handle(
        _interestLevelIdMeta,
        interestLevelId.isAcceptableOrUnknown(
          data['interest_level_id']!,
          _interestLevelIdMeta,
        ),
      );
    }
    if (data.containsKey('next_followup_date')) {
      context.handle(
        _nextFollowupDateMeta,
        nextFollowupDate.isAcceptableOrUnknown(
          data['next_followup_date']!,
          _nextFollowupDateMeta,
        ),
      );
    }
    if (data.containsKey('raw')) {
      context.handle(
        _rawMeta,
        raw.isAcceptableOrUnknown(data['raw']!, _rawMeta),
      );
    } else if (isInserting) {
      context.missing(_rawMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LeadsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeadsCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_name'],
      )!,
      contactPerson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_person'],
      )!,
      contactNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_no'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      interestLevelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interest_level_id'],
      ),
      nextFollowupDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_followup_date'],
      ),
      raw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $LeadsCacheTable createAlias(String alias) {
    return $LeadsCacheTable(attachedDatabase, alias);
  }
}

class LeadsCacheData extends DataClass implements Insertable<LeadsCacheData> {
  final String id;
  final String companyName;
  final String contactPerson;
  final String contactNo;
  final String status;
  final String? interestLevelId;
  final String? nextFollowupDate;
  final String raw;
  final String syncState;
  final DateTime cachedAt;
  const LeadsCacheData({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.contactNo,
    required this.status,
    this.interestLevelId,
    this.nextFollowupDate,
    required this.raw,
    required this.syncState,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_name'] = Variable<String>(companyName);
    map['contact_person'] = Variable<String>(contactPerson);
    map['contact_no'] = Variable<String>(contactNo);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || interestLevelId != null) {
      map['interest_level_id'] = Variable<String>(interestLevelId);
    }
    if (!nullToAbsent || nextFollowupDate != null) {
      map['next_followup_date'] = Variable<String>(nextFollowupDate);
    }
    map['raw'] = Variable<String>(raw);
    map['sync_state'] = Variable<String>(syncState);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  LeadsCacheCompanion toCompanion(bool nullToAbsent) {
    return LeadsCacheCompanion(
      id: Value(id),
      companyName: Value(companyName),
      contactPerson: Value(contactPerson),
      contactNo: Value(contactNo),
      status: Value(status),
      interestLevelId: interestLevelId == null && nullToAbsent
          ? const Value.absent()
          : Value(interestLevelId),
      nextFollowupDate: nextFollowupDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextFollowupDate),
      raw: Value(raw),
      syncState: Value(syncState),
      cachedAt: Value(cachedAt),
    );
  }

  factory LeadsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeadsCacheData(
      id: serializer.fromJson<String>(json['id']),
      companyName: serializer.fromJson<String>(json['companyName']),
      contactPerson: serializer.fromJson<String>(json['contactPerson']),
      contactNo: serializer.fromJson<String>(json['contactNo']),
      status: serializer.fromJson<String>(json['status']),
      interestLevelId: serializer.fromJson<String?>(json['interestLevelId']),
      nextFollowupDate: serializer.fromJson<String?>(json['nextFollowupDate']),
      raw: serializer.fromJson<String>(json['raw']),
      syncState: serializer.fromJson<String>(json['syncState']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyName': serializer.toJson<String>(companyName),
      'contactPerson': serializer.toJson<String>(contactPerson),
      'contactNo': serializer.toJson<String>(contactNo),
      'status': serializer.toJson<String>(status),
      'interestLevelId': serializer.toJson<String?>(interestLevelId),
      'nextFollowupDate': serializer.toJson<String?>(nextFollowupDate),
      'raw': serializer.toJson<String>(raw),
      'syncState': serializer.toJson<String>(syncState),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  LeadsCacheData copyWith({
    String? id,
    String? companyName,
    String? contactPerson,
    String? contactNo,
    String? status,
    Value<String?> interestLevelId = const Value.absent(),
    Value<String?> nextFollowupDate = const Value.absent(),
    String? raw,
    String? syncState,
    DateTime? cachedAt,
  }) => LeadsCacheData(
    id: id ?? this.id,
    companyName: companyName ?? this.companyName,
    contactPerson: contactPerson ?? this.contactPerson,
    contactNo: contactNo ?? this.contactNo,
    status: status ?? this.status,
    interestLevelId: interestLevelId.present
        ? interestLevelId.value
        : this.interestLevelId,
    nextFollowupDate: nextFollowupDate.present
        ? nextFollowupDate.value
        : this.nextFollowupDate,
    raw: raw ?? this.raw,
    syncState: syncState ?? this.syncState,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  LeadsCacheData copyWithCompanion(LeadsCacheCompanion data) {
    return LeadsCacheData(
      id: data.id.present ? data.id.value : this.id,
      companyName: data.companyName.present
          ? data.companyName.value
          : this.companyName,
      contactPerson: data.contactPerson.present
          ? data.contactPerson.value
          : this.contactPerson,
      contactNo: data.contactNo.present ? data.contactNo.value : this.contactNo,
      status: data.status.present ? data.status.value : this.status,
      interestLevelId: data.interestLevelId.present
          ? data.interestLevelId.value
          : this.interestLevelId,
      nextFollowupDate: data.nextFollowupDate.present
          ? data.nextFollowupDate.value
          : this.nextFollowupDate,
      raw: data.raw.present ? data.raw.value : this.raw,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeadsCacheData(')
          ..write('id: $id, ')
          ..write('companyName: $companyName, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('contactNo: $contactNo, ')
          ..write('status: $status, ')
          ..write('interestLevelId: $interestLevelId, ')
          ..write('nextFollowupDate: $nextFollowupDate, ')
          ..write('raw: $raw, ')
          ..write('syncState: $syncState, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyName,
    contactPerson,
    contactNo,
    status,
    interestLevelId,
    nextFollowupDate,
    raw,
    syncState,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeadsCacheData &&
          other.id == this.id &&
          other.companyName == this.companyName &&
          other.contactPerson == this.contactPerson &&
          other.contactNo == this.contactNo &&
          other.status == this.status &&
          other.interestLevelId == this.interestLevelId &&
          other.nextFollowupDate == this.nextFollowupDate &&
          other.raw == this.raw &&
          other.syncState == this.syncState &&
          other.cachedAt == this.cachedAt);
}

class LeadsCacheCompanion extends UpdateCompanion<LeadsCacheData> {
  final Value<String> id;
  final Value<String> companyName;
  final Value<String> contactPerson;
  final Value<String> contactNo;
  final Value<String> status;
  final Value<String?> interestLevelId;
  final Value<String?> nextFollowupDate;
  final Value<String> raw;
  final Value<String> syncState;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const LeadsCacheCompanion({
    this.id = const Value.absent(),
    this.companyName = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.contactNo = const Value.absent(),
    this.status = const Value.absent(),
    this.interestLevelId = const Value.absent(),
    this.nextFollowupDate = const Value.absent(),
    this.raw = const Value.absent(),
    this.syncState = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeadsCacheCompanion.insert({
    required String id,
    required String companyName,
    required String contactPerson,
    required String contactNo,
    required String status,
    this.interestLevelId = const Value.absent(),
    this.nextFollowupDate = const Value.absent(),
    required String raw,
    this.syncState = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyName = Value(companyName),
       contactPerson = Value(contactPerson),
       contactNo = Value(contactNo),
       status = Value(status),
       raw = Value(raw),
       cachedAt = Value(cachedAt);
  static Insertable<LeadsCacheData> custom({
    Expression<String>? id,
    Expression<String>? companyName,
    Expression<String>? contactPerson,
    Expression<String>? contactNo,
    Expression<String>? status,
    Expression<String>? interestLevelId,
    Expression<String>? nextFollowupDate,
    Expression<String>? raw,
    Expression<String>? syncState,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyName != null) 'company_name': companyName,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (contactNo != null) 'contact_no': contactNo,
      if (status != null) 'status': status,
      if (interestLevelId != null) 'interest_level_id': interestLevelId,
      if (nextFollowupDate != null) 'next_followup_date': nextFollowupDate,
      if (raw != null) 'raw': raw,
      if (syncState != null) 'sync_state': syncState,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeadsCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? companyName,
    Value<String>? contactPerson,
    Value<String>? contactNo,
    Value<String>? status,
    Value<String?>? interestLevelId,
    Value<String?>? nextFollowupDate,
    Value<String>? raw,
    Value<String>? syncState,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return LeadsCacheCompanion(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      contactPerson: contactPerson ?? this.contactPerson,
      contactNo: contactNo ?? this.contactNo,
      status: status ?? this.status,
      interestLevelId: interestLevelId ?? this.interestLevelId,
      nextFollowupDate: nextFollowupDate ?? this.nextFollowupDate,
      raw: raw ?? this.raw,
      syncState: syncState ?? this.syncState,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyName.present) {
      map['company_name'] = Variable<String>(companyName.value);
    }
    if (contactPerson.present) {
      map['contact_person'] = Variable<String>(contactPerson.value);
    }
    if (contactNo.present) {
      map['contact_no'] = Variable<String>(contactNo.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (interestLevelId.present) {
      map['interest_level_id'] = Variable<String>(interestLevelId.value);
    }
    if (nextFollowupDate.present) {
      map['next_followup_date'] = Variable<String>(nextFollowupDate.value);
    }
    if (raw.present) {
      map['raw'] = Variable<String>(raw.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeadsCacheCompanion(')
          ..write('id: $id, ')
          ..write('companyName: $companyName, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('contactNo: $contactNo, ')
          ..write('status: $status, ')
          ..write('interestLevelId: $interestLevelId, ')
          ..write('nextFollowupDate: $nextFollowupDate, ')
          ..write('raw: $raw, ')
          ..write('syncState: $syncState, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitsCacheTable extends VisitsCache
    with TableInfo<$VisitsCacheTable, VisitsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leadIdMeta = const VerificationMeta('leadId');
  @override
  late final GeneratedColumn<String> leadId = GeneratedColumn<String>(
    'lead_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitDateMeta = const VerificationMeta(
    'visitDate',
  );
  @override
  late final GeneratedColumn<String> visitDate = GeneratedColumn<String>(
    'visit_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledTimeMeta = const VerificationMeta(
    'scheduledTime',
  );
  @override
  late final GeneratedColumn<String> scheduledTime = GeneratedColumn<String>(
    'scheduled_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visitTypeMeta = const VerificationMeta(
    'visitType',
  );
  @override
  late final GeneratedColumn<String> visitType = GeneratedColumn<String>(
    'visit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawMeta = const VerificationMeta('raw');
  @override
  late final GeneratedColumn<String> raw = GeneratedColumn<String>(
    'raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    leadId,
    visitDate,
    scheduledTime,
    visitType,
    status,
    raw,
    syncState,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitsCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lead_id')) {
      context.handle(
        _leadIdMeta,
        leadId.isAcceptableOrUnknown(data['lead_id']!, _leadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_leadIdMeta);
    }
    if (data.containsKey('visit_date')) {
      context.handle(
        _visitDateMeta,
        visitDate.isAcceptableOrUnknown(data['visit_date']!, _visitDateMeta),
      );
    } else if (isInserting) {
      context.missing(_visitDateMeta);
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
        _scheduledTimeMeta,
        scheduledTime.isAcceptableOrUnknown(
          data['scheduled_time']!,
          _scheduledTimeMeta,
        ),
      );
    }
    if (data.containsKey('visit_type')) {
      context.handle(
        _visitTypeMeta,
        visitType.isAcceptableOrUnknown(data['visit_type']!, _visitTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_visitTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('raw')) {
      context.handle(
        _rawMeta,
        raw.isAcceptableOrUnknown(data['raw']!, _rawMeta),
      );
    } else if (isInserting) {
      context.missing(_rawMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VisitsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitsCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      leadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lead_id'],
      )!,
      visitDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_date'],
      )!,
      scheduledTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scheduled_time'],
      ),
      visitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      raw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $VisitsCacheTable createAlias(String alias) {
    return $VisitsCacheTable(attachedDatabase, alias);
  }
}

class VisitsCacheData extends DataClass implements Insertable<VisitsCacheData> {
  final String id;
  final String leadId;
  final String visitDate;
  final String? scheduledTime;
  final String visitType;
  final String status;
  final String raw;
  final String syncState;
  final DateTime cachedAt;
  const VisitsCacheData({
    required this.id,
    required this.leadId,
    required this.visitDate,
    this.scheduledTime,
    required this.visitType,
    required this.status,
    required this.raw,
    required this.syncState,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lead_id'] = Variable<String>(leadId);
    map['visit_date'] = Variable<String>(visitDate);
    if (!nullToAbsent || scheduledTime != null) {
      map['scheduled_time'] = Variable<String>(scheduledTime);
    }
    map['visit_type'] = Variable<String>(visitType);
    map['status'] = Variable<String>(status);
    map['raw'] = Variable<String>(raw);
    map['sync_state'] = Variable<String>(syncState);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  VisitsCacheCompanion toCompanion(bool nullToAbsent) {
    return VisitsCacheCompanion(
      id: Value(id),
      leadId: Value(leadId),
      visitDate: Value(visitDate),
      scheduledTime: scheduledTime == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledTime),
      visitType: Value(visitType),
      status: Value(status),
      raw: Value(raw),
      syncState: Value(syncState),
      cachedAt: Value(cachedAt),
    );
  }

  factory VisitsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitsCacheData(
      id: serializer.fromJson<String>(json['id']),
      leadId: serializer.fromJson<String>(json['leadId']),
      visitDate: serializer.fromJson<String>(json['visitDate']),
      scheduledTime: serializer.fromJson<String?>(json['scheduledTime']),
      visitType: serializer.fromJson<String>(json['visitType']),
      status: serializer.fromJson<String>(json['status']),
      raw: serializer.fromJson<String>(json['raw']),
      syncState: serializer.fromJson<String>(json['syncState']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'leadId': serializer.toJson<String>(leadId),
      'visitDate': serializer.toJson<String>(visitDate),
      'scheduledTime': serializer.toJson<String?>(scheduledTime),
      'visitType': serializer.toJson<String>(visitType),
      'status': serializer.toJson<String>(status),
      'raw': serializer.toJson<String>(raw),
      'syncState': serializer.toJson<String>(syncState),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  VisitsCacheData copyWith({
    String? id,
    String? leadId,
    String? visitDate,
    Value<String?> scheduledTime = const Value.absent(),
    String? visitType,
    String? status,
    String? raw,
    String? syncState,
    DateTime? cachedAt,
  }) => VisitsCacheData(
    id: id ?? this.id,
    leadId: leadId ?? this.leadId,
    visitDate: visitDate ?? this.visitDate,
    scheduledTime: scheduledTime.present
        ? scheduledTime.value
        : this.scheduledTime,
    visitType: visitType ?? this.visitType,
    status: status ?? this.status,
    raw: raw ?? this.raw,
    syncState: syncState ?? this.syncState,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  VisitsCacheData copyWithCompanion(VisitsCacheCompanion data) {
    return VisitsCacheData(
      id: data.id.present ? data.id.value : this.id,
      leadId: data.leadId.present ? data.leadId.value : this.leadId,
      visitDate: data.visitDate.present ? data.visitDate.value : this.visitDate,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      visitType: data.visitType.present ? data.visitType.value : this.visitType,
      status: data.status.present ? data.status.value : this.status,
      raw: data.raw.present ? data.raw.value : this.raw,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitsCacheData(')
          ..write('id: $id, ')
          ..write('leadId: $leadId, ')
          ..write('visitDate: $visitDate, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('visitType: $visitType, ')
          ..write('status: $status, ')
          ..write('raw: $raw, ')
          ..write('syncState: $syncState, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    leadId,
    visitDate,
    scheduledTime,
    visitType,
    status,
    raw,
    syncState,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitsCacheData &&
          other.id == this.id &&
          other.leadId == this.leadId &&
          other.visitDate == this.visitDate &&
          other.scheduledTime == this.scheduledTime &&
          other.visitType == this.visitType &&
          other.status == this.status &&
          other.raw == this.raw &&
          other.syncState == this.syncState &&
          other.cachedAt == this.cachedAt);
}

class VisitsCacheCompanion extends UpdateCompanion<VisitsCacheData> {
  final Value<String> id;
  final Value<String> leadId;
  final Value<String> visitDate;
  final Value<String?> scheduledTime;
  final Value<String> visitType;
  final Value<String> status;
  final Value<String> raw;
  final Value<String> syncState;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const VisitsCacheCompanion({
    this.id = const Value.absent(),
    this.leadId = const Value.absent(),
    this.visitDate = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.visitType = const Value.absent(),
    this.status = const Value.absent(),
    this.raw = const Value.absent(),
    this.syncState = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitsCacheCompanion.insert({
    required String id,
    required String leadId,
    required String visitDate,
    this.scheduledTime = const Value.absent(),
    required String visitType,
    required String status,
    required String raw,
    this.syncState = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       leadId = Value(leadId),
       visitDate = Value(visitDate),
       visitType = Value(visitType),
       status = Value(status),
       raw = Value(raw),
       cachedAt = Value(cachedAt);
  static Insertable<VisitsCacheData> custom({
    Expression<String>? id,
    Expression<String>? leadId,
    Expression<String>? visitDate,
    Expression<String>? scheduledTime,
    Expression<String>? visitType,
    Expression<String>? status,
    Expression<String>? raw,
    Expression<String>? syncState,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (leadId != null) 'lead_id': leadId,
      if (visitDate != null) 'visit_date': visitDate,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (visitType != null) 'visit_type': visitType,
      if (status != null) 'status': status,
      if (raw != null) 'raw': raw,
      if (syncState != null) 'sync_state': syncState,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitsCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? leadId,
    Value<String>? visitDate,
    Value<String?>? scheduledTime,
    Value<String>? visitType,
    Value<String>? status,
    Value<String>? raw,
    Value<String>? syncState,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return VisitsCacheCompanion(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      visitDate: visitDate ?? this.visitDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      visitType: visitType ?? this.visitType,
      status: status ?? this.status,
      raw: raw ?? this.raw,
      syncState: syncState ?? this.syncState,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (leadId.present) {
      map['lead_id'] = Variable<String>(leadId.value);
    }
    if (visitDate.present) {
      map['visit_date'] = Variable<String>(visitDate.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<String>(scheduledTime.value);
    }
    if (visitType.present) {
      map['visit_type'] = Variable<String>(visitType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (raw.present) {
      map['raw'] = Variable<String>(raw.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsCacheCompanion(')
          ..write('id: $id, ')
          ..write('leadId: $leadId, ')
          ..write('visitDate: $visitDate, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('visitType: $visitType, ')
          ..write('status: $status, ')
          ..write('raw: $raw, ')
          ..write('syncState: $syncState, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxEntriesTable extends OutboxEntries
    with TableInfo<$OutboxEntriesTable, OutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    operation,
    localId,
    payloadJson,
    createdAt,
    attemptCount,
    lastError,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $OutboxEntriesTable createAlias(String alias) {
    return $OutboxEntriesTable(attachedDatabase, alias);
  }
}

class OutboxEntry extends DataClass implements Insertable<OutboxEntry> {
  final int id;
  final String entityType;
  final String operation;
  final String localId;
  final String payloadJson;
  final DateTime createdAt;
  final int attemptCount;
  final String? lastError;
  final String status;
  const OutboxEntry({
    required this.id,
    required this.entityType,
    required this.operation,
    required this.localId,
    required this.payloadJson,
    required this.createdAt,
    required this.attemptCount,
    this.lastError,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['operation'] = Variable<String>(operation);
    map['local_id'] = Variable<String>(localId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  OutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return OutboxEntriesCompanion(
      id: Value(id),
      entityType: Value(entityType),
      operation: Value(operation),
      localId: Value(localId),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      attemptCount: Value(attemptCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      status: Value(status),
    );
  }

  factory OutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntry(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      operation: serializer.fromJson<String>(json['operation']),
      localId: serializer.fromJson<String>(json['localId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'operation': serializer.toJson<String>(operation),
      'localId': serializer.toJson<String>(localId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastError': serializer.toJson<String?>(lastError),
      'status': serializer.toJson<String>(status),
    };
  }

  OutboxEntry copyWith({
    int? id,
    String? entityType,
    String? operation,
    String? localId,
    String? payloadJson,
    DateTime? createdAt,
    int? attemptCount,
    Value<String?> lastError = const Value.absent(),
    String? status,
  }) => OutboxEntry(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    operation: operation ?? this.operation,
    localId: localId ?? this.localId,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    attemptCount: attemptCount ?? this.attemptCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    status: status ?? this.status,
  );
  OutboxEntry copyWithCompanion(OutboxEntriesCompanion data) {
    return OutboxEntry(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      operation: data.operation.present ? data.operation.value : this.operation,
      localId: data.localId.present ? data.localId.value : this.localId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntry(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('operation: $operation, ')
          ..write('localId: $localId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    operation,
    localId,
    payloadJson,
    createdAt,
    attemptCount,
    lastError,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntry &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.operation == this.operation &&
          other.localId == this.localId &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.attemptCount == this.attemptCount &&
          other.lastError == this.lastError &&
          other.status == this.status);
}

class OutboxEntriesCompanion extends UpdateCompanion<OutboxEntry> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> operation;
  final Value<String> localId;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> attemptCount;
  final Value<String?> lastError;
  final Value<String> status;
  const OutboxEntriesCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.operation = const Value.absent(),
    this.localId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
  });
  OutboxEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String operation,
    required String localId,
    required String payloadJson,
    required DateTime createdAt,
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
  }) : entityType = Value(entityType),
       operation = Value(operation),
       localId = Value(localId),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<OutboxEntry> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? operation,
    Expression<String>? localId,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? attemptCount,
    Expression<String>? lastError,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (operation != null) 'operation': operation,
      if (localId != null) 'local_id': localId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastError != null) 'last_error': lastError,
      if (status != null) 'status': status,
    });
  }

  OutboxEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? operation,
    Value<String>? localId,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<int>? attemptCount,
    Value<String?>? lastError,
    Value<String>? status,
  }) {
    return OutboxEntriesCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      operation: operation ?? this.operation,
      localId: localId ?? this.localId,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntriesCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('operation: $operation, ')
          ..write('localId: $localId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LeadsCacheTable leadsCache = $LeadsCacheTable(this);
  late final $VisitsCacheTable visitsCache = $VisitsCacheTable(this);
  late final $OutboxEntriesTable outboxEntries = $OutboxEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    leadsCache,
    visitsCache,
    outboxEntries,
  ];
}

typedef $$LeadsCacheTableCreateCompanionBuilder =
    LeadsCacheCompanion Function({
      required String id,
      required String companyName,
      required String contactPerson,
      required String contactNo,
      required String status,
      Value<String?> interestLevelId,
      Value<String?> nextFollowupDate,
      required String raw,
      Value<String> syncState,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$LeadsCacheTableUpdateCompanionBuilder =
    LeadsCacheCompanion Function({
      Value<String> id,
      Value<String> companyName,
      Value<String> contactPerson,
      Value<String> contactNo,
      Value<String> status,
      Value<String?> interestLevelId,
      Value<String?> nextFollowupDate,
      Value<String> raw,
      Value<String> syncState,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$LeadsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $LeadsCacheTable> {
  $$LeadsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactNo => $composableBuilder(
    column: $table.contactNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interestLevelId => $composableBuilder(
    column: $table.interestLevelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextFollowupDate => $composableBuilder(
    column: $table.nextFollowupDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeadsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $LeadsCacheTable> {
  $$LeadsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactNo => $composableBuilder(
    column: $table.contactNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interestLevelId => $composableBuilder(
    column: $table.interestLevelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextFollowupDate => $composableBuilder(
    column: $table.nextFollowupDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeadsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeadsCacheTable> {
  $$LeadsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactNo =>
      $composableBuilder(column: $table.contactNo, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get interestLevelId => $composableBuilder(
    column: $table.interestLevelId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextFollowupDate => $composableBuilder(
    column: $table.nextFollowupDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get raw =>
      $composableBuilder(column: $table.raw, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$LeadsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeadsCacheTable,
          LeadsCacheData,
          $$LeadsCacheTableFilterComposer,
          $$LeadsCacheTableOrderingComposer,
          $$LeadsCacheTableAnnotationComposer,
          $$LeadsCacheTableCreateCompanionBuilder,
          $$LeadsCacheTableUpdateCompanionBuilder,
          (
            LeadsCacheData,
            BaseReferences<_$AppDatabase, $LeadsCacheTable, LeadsCacheData>,
          ),
          LeadsCacheData,
          PrefetchHooks Function()
        > {
  $$LeadsCacheTableTableManager(_$AppDatabase db, $LeadsCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeadsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeadsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeadsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyName = const Value.absent(),
                Value<String> contactPerson = const Value.absent(),
                Value<String> contactNo = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> interestLevelId = const Value.absent(),
                Value<String?> nextFollowupDate = const Value.absent(),
                Value<String> raw = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeadsCacheCompanion(
                id: id,
                companyName: companyName,
                contactPerson: contactPerson,
                contactNo: contactNo,
                status: status,
                interestLevelId: interestLevelId,
                nextFollowupDate: nextFollowupDate,
                raw: raw,
                syncState: syncState,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyName,
                required String contactPerson,
                required String contactNo,
                required String status,
                Value<String?> interestLevelId = const Value.absent(),
                Value<String?> nextFollowupDate = const Value.absent(),
                required String raw,
                Value<String> syncState = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => LeadsCacheCompanion.insert(
                id: id,
                companyName: companyName,
                contactPerson: contactPerson,
                contactNo: contactNo,
                status: status,
                interestLevelId: interestLevelId,
                nextFollowupDate: nextFollowupDate,
                raw: raw,
                syncState: syncState,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeadsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeadsCacheTable,
      LeadsCacheData,
      $$LeadsCacheTableFilterComposer,
      $$LeadsCacheTableOrderingComposer,
      $$LeadsCacheTableAnnotationComposer,
      $$LeadsCacheTableCreateCompanionBuilder,
      $$LeadsCacheTableUpdateCompanionBuilder,
      (
        LeadsCacheData,
        BaseReferences<_$AppDatabase, $LeadsCacheTable, LeadsCacheData>,
      ),
      LeadsCacheData,
      PrefetchHooks Function()
    >;
typedef $$VisitsCacheTableCreateCompanionBuilder =
    VisitsCacheCompanion Function({
      required String id,
      required String leadId,
      required String visitDate,
      Value<String?> scheduledTime,
      required String visitType,
      required String status,
      required String raw,
      Value<String> syncState,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$VisitsCacheTableUpdateCompanionBuilder =
    VisitsCacheCompanion Function({
      Value<String> id,
      Value<String> leadId,
      Value<String> visitDate,
      Value<String?> scheduledTime,
      Value<String> visitType,
      Value<String> status,
      Value<String> raw,
      Value<String> syncState,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$VisitsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $VisitsCacheTable> {
  $$VisitsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leadId => $composableBuilder(
    column: $table.leadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitDate => $composableBuilder(
    column: $table.visitDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitType => $composableBuilder(
    column: $table.visitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitsCacheTable> {
  $$VisitsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leadId => $composableBuilder(
    column: $table.leadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitDate => $composableBuilder(
    column: $table.visitDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitType => $composableBuilder(
    column: $table.visitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitsCacheTable> {
  $$VisitsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get leadId =>
      $composableBuilder(column: $table.leadId, builder: (column) => column);

  GeneratedColumn<String> get visitDate =>
      $composableBuilder(column: $table.visitDate, builder: (column) => column);

  GeneratedColumn<String> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get visitType =>
      $composableBuilder(column: $table.visitType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get raw =>
      $composableBuilder(column: $table.raw, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$VisitsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitsCacheTable,
          VisitsCacheData,
          $$VisitsCacheTableFilterComposer,
          $$VisitsCacheTableOrderingComposer,
          $$VisitsCacheTableAnnotationComposer,
          $$VisitsCacheTableCreateCompanionBuilder,
          $$VisitsCacheTableUpdateCompanionBuilder,
          (
            VisitsCacheData,
            BaseReferences<_$AppDatabase, $VisitsCacheTable, VisitsCacheData>,
          ),
          VisitsCacheData,
          PrefetchHooks Function()
        > {
  $$VisitsCacheTableTableManager(_$AppDatabase db, $VisitsCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> leadId = const Value.absent(),
                Value<String> visitDate = const Value.absent(),
                Value<String?> scheduledTime = const Value.absent(),
                Value<String> visitType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> raw = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsCacheCompanion(
                id: id,
                leadId: leadId,
                visitDate: visitDate,
                scheduledTime: scheduledTime,
                visitType: visitType,
                status: status,
                raw: raw,
                syncState: syncState,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String leadId,
                required String visitDate,
                Value<String?> scheduledTime = const Value.absent(),
                required String visitType,
                required String status,
                required String raw,
                Value<String> syncState = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => VisitsCacheCompanion.insert(
                id: id,
                leadId: leadId,
                visitDate: visitDate,
                scheduledTime: scheduledTime,
                visitType: visitType,
                status: status,
                raw: raw,
                syncState: syncState,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitsCacheTable,
      VisitsCacheData,
      $$VisitsCacheTableFilterComposer,
      $$VisitsCacheTableOrderingComposer,
      $$VisitsCacheTableAnnotationComposer,
      $$VisitsCacheTableCreateCompanionBuilder,
      $$VisitsCacheTableUpdateCompanionBuilder,
      (
        VisitsCacheData,
        BaseReferences<_$AppDatabase, $VisitsCacheTable, VisitsCacheData>,
      ),
      VisitsCacheData,
      PrefetchHooks Function()
    >;
typedef $$OutboxEntriesTableCreateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> id,
      required String entityType,
      required String operation,
      required String localId,
      required String payloadJson,
      required DateTime createdAt,
      Value<int> attemptCount,
      Value<String?> lastError,
      Value<String> status,
    });
typedef $$OutboxEntriesTableUpdateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> operation,
      Value<String> localId,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<int> attemptCount,
      Value<String?> lastError,
      Value<String> status,
    });

class $$OutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$OutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxEntriesTable,
          OutboxEntry,
          $$OutboxEntriesTableFilterComposer,
          $$OutboxEntriesTableOrderingComposer,
          $$OutboxEntriesTableAnnotationComposer,
          $$OutboxEntriesTableCreateCompanionBuilder,
          $$OutboxEntriesTableUpdateCompanionBuilder,
          (
            OutboxEntry,
            BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntry>,
          ),
          OutboxEntry,
          PrefetchHooks Function()
        > {
  $$OutboxEntriesTableTableManager(_$AppDatabase db, $OutboxEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> localId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => OutboxEntriesCompanion(
                id: id,
                entityType: entityType,
                operation: operation,
                localId: localId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                attemptCount: attemptCount,
                lastError: lastError,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String operation,
                required String localId,
                required String payloadJson,
                required DateTime createdAt,
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => OutboxEntriesCompanion.insert(
                id: id,
                entityType: entityType,
                operation: operation,
                localId: localId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                attemptCount: attemptCount,
                lastError: lastError,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxEntriesTable,
      OutboxEntry,
      $$OutboxEntriesTableFilterComposer,
      $$OutboxEntriesTableOrderingComposer,
      $$OutboxEntriesTableAnnotationComposer,
      $$OutboxEntriesTableCreateCompanionBuilder,
      $$OutboxEntriesTableUpdateCompanionBuilder,
      (
        OutboxEntry,
        BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntry>,
      ),
      OutboxEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LeadsCacheTableTableManager get leadsCache =>
      $$LeadsCacheTableTableManager(_db, _db.leadsCache);
  $$VisitsCacheTableTableManager get visitsCache =>
      $$VisitsCacheTableTableManager(_db, _db.visitsCache);
  $$OutboxEntriesTableTableManager get outboxEntries =>
      $$OutboxEntriesTableTableManager(_db, _db.outboxEntries);
}
