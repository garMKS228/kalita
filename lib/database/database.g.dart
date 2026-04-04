// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $WalletsTable extends Wallets with TableInfo<$WalletsTable, Wallet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Wallet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Wallet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Wallet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
    );
  }

  @override
  $WalletsTable createAlias(String alias) {
    return $WalletsTable(attachedDatabase, alias);
  }
}

class Wallet extends DataClass implements Insertable<Wallet> {
  final int id;
  final String name;
  final String color;
  const Wallet({required this.id, required this.name, required this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    return map;
  }

  WalletsCompanion toCompanion(bool nullToAbsent) {
    return WalletsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
    );
  }

  factory Wallet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wallet(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
    };
  }

  Wallet copyWith({int? id, String? name, String? color}) => Wallet(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
  );
  Wallet copyWithCompanion(WalletsCompanion data) {
    return Wallet(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Wallet(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wallet &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color);
}

class WalletsCompanion extends UpdateCompanion<Wallet> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> color;
  const WalletsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
  });
  WalletsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String color,
  }) : name = Value(name),
       color = Value(color);
  static Insertable<Wallet> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
    });
  }

  WalletsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? color,
  }) {
    return WalletsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _system_tagMeta = const VerificationMeta(
    'system_tag',
  );
  @override
  late final GeneratedColumn<String> system_tag = GeneratedColumn<String>(
    'system_tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _icon_nameMeta = const VerificationMeta(
    'icon_name',
  );
  @override
  late final GeneratedColumn<String> icon_name = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, system_tag, icon_name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('system_tag')) {
      context.handle(
        _system_tagMeta,
        system_tag.isAcceptableOrUnknown(data['system_tag']!, _system_tagMeta),
      );
    } else if (isInserting) {
      context.missing(_system_tagMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _icon_nameMeta,
        icon_name.isAcceptableOrUnknown(data['icon_name']!, _icon_nameMeta),
      );
    } else if (isInserting) {
      context.missing(_icon_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      system_tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_tag'],
      )!,
      icon_name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String system_tag;
  final String icon_name;
  const Category({
    required this.id,
    required this.name,
    required this.system_tag,
    required this.icon_name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['system_tag'] = Variable<String>(system_tag);
    map['icon_name'] = Variable<String>(icon_name);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      system_tag: Value(system_tag),
      icon_name: Value(icon_name),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      system_tag: serializer.fromJson<String>(json['system_tag']),
      icon_name: serializer.fromJson<String>(json['icon_name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'system_tag': serializer.toJson<String>(system_tag),
      'icon_name': serializer.toJson<String>(icon_name),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? system_tag,
    String? icon_name,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    system_tag: system_tag ?? this.system_tag,
    icon_name: icon_name ?? this.icon_name,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      system_tag: data.system_tag.present
          ? data.system_tag.value
          : this.system_tag,
      icon_name: data.icon_name.present ? data.icon_name.value : this.icon_name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('system_tag: $system_tag, ')
          ..write('icon_name: $icon_name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, system_tag, icon_name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.system_tag == this.system_tag &&
          other.icon_name == this.icon_name);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> system_tag;
  final Value<String> icon_name;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.system_tag = const Value.absent(),
    this.icon_name = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String system_tag,
    required String icon_name,
  }) : name = Value(name),
       system_tag = Value(system_tag),
       icon_name = Value(icon_name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? system_tag,
    Expression<String>? icon_name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (system_tag != null) 'system_tag': system_tag,
      if (icon_name != null) 'icon_name': icon_name,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? system_tag,
    Value<String>? icon_name,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      system_tag: system_tag ?? this.system_tag,
      icon_name: icon_name ?? this.icon_name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (system_tag.present) {
      map['system_tag'] = Variable<String>(system_tag.value);
    }
    if (icon_name.present) {
      map['icon_name'] = Variable<String>(icon_name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('system_tag: $system_tag, ')
          ..write('icon_name: $icon_name')
          ..write(')'))
        .toString();
  }
}

class $CardsTable extends Cards with TableInfo<$CardsTable, CardEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _wallet_idMeta = const VerificationMeta(
    'wallet_id',
  );
  @override
  late final GeneratedColumn<int> wallet_id = GeneratedColumn<int>(
    'wallet_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wallets (id)',
    ),
  );
  static const VerificationMeta _category_idMeta = const VerificationMeta(
    'category_id',
  );
  @override
  late final GeneratedColumn<int> category_id = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcode_dataMeta = const VerificationMeta(
    'barcode_data',
  );
  @override
  late final GeneratedColumn<String> barcode_data = GeneratedColumn<String>(
    'barcode_data',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcode_typeMeta = const VerificationMeta(
    'barcode_type',
  );
  @override
  late final GeneratedColumn<String> barcode_type = GeneratedColumn<String>(
    'barcode_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _is_favoriteMeta = const VerificationMeta(
    'is_favorite',
  );
  @override
  late final GeneratedColumn<bool> is_favorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lat_usedMeta = const VerificationMeta(
    'lat_used',
  );
  @override
  late final GeneratedColumn<DateTime> lat_used = GeneratedColumn<DateTime>(
    'lat_used',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wallet_id,
    category_id,
    title,
    barcode_data,
    barcode_type,
    color,
    is_favorite,
    lat_used,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _wallet_idMeta,
        wallet_id.isAcceptableOrUnknown(data['wallet_id']!, _wallet_idMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _category_idMeta,
        category_id.isAcceptableOrUnknown(
          data['category_id']!,
          _category_idMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('barcode_data')) {
      context.handle(
        _barcode_dataMeta,
        barcode_data.isAcceptableOrUnknown(
          data['barcode_data']!,
          _barcode_dataMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_barcode_dataMeta);
    }
    if (data.containsKey('barcode_type')) {
      context.handle(
        _barcode_typeMeta,
        barcode_type.isAcceptableOrUnknown(
          data['barcode_type']!,
          _barcode_typeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_barcode_typeMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _is_favoriteMeta,
        is_favorite.isAcceptableOrUnknown(
          data['is_favorite']!,
          _is_favoriteMeta,
        ),
      );
    }
    if (data.containsKey('lat_used')) {
      context.handle(
        _lat_usedMeta,
        lat_used.isAcceptableOrUnknown(data['lat_used']!, _lat_usedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      wallet_id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wallet_id'],
      ),
      category_id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      barcode_data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode_data'],
      )!,
      barcode_type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode_type'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      is_favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      lat_used: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}lat_used'],
      ),
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class CardEntry extends DataClass implements Insertable<CardEntry> {
  final int id;
  final int? wallet_id;
  final int? category_id;
  final String title;
  final String barcode_data;
  final String barcode_type;
  final String? color;
  final bool is_favorite;
  final DateTime? lat_used;
  const CardEntry({
    required this.id,
    this.wallet_id,
    this.category_id,
    required this.title,
    required this.barcode_data,
    required this.barcode_type,
    this.color,
    required this.is_favorite,
    this.lat_used,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || wallet_id != null) {
      map['wallet_id'] = Variable<int>(wallet_id);
    }
    if (!nullToAbsent || category_id != null) {
      map['category_id'] = Variable<int>(category_id);
    }
    map['title'] = Variable<String>(title);
    map['barcode_data'] = Variable<String>(barcode_data);
    map['barcode_type'] = Variable<String>(barcode_type);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['is_favorite'] = Variable<bool>(is_favorite);
    if (!nullToAbsent || lat_used != null) {
      map['lat_used'] = Variable<DateTime>(lat_used);
    }
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      wallet_id: wallet_id == null && nullToAbsent
          ? const Value.absent()
          : Value(wallet_id),
      category_id: category_id == null && nullToAbsent
          ? const Value.absent()
          : Value(category_id),
      title: Value(title),
      barcode_data: Value(barcode_data),
      barcode_type: Value(barcode_type),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      is_favorite: Value(is_favorite),
      lat_used: lat_used == null && nullToAbsent
          ? const Value.absent()
          : Value(lat_used),
    );
  }

  factory CardEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardEntry(
      id: serializer.fromJson<int>(json['id']),
      wallet_id: serializer.fromJson<int?>(json['wallet_id']),
      category_id: serializer.fromJson<int?>(json['category_id']),
      title: serializer.fromJson<String>(json['title']),
      barcode_data: serializer.fromJson<String>(json['barcode_data']),
      barcode_type: serializer.fromJson<String>(json['barcode_type']),
      color: serializer.fromJson<String?>(json['color']),
      is_favorite: serializer.fromJson<bool>(json['is_favorite']),
      lat_used: serializer.fromJson<DateTime?>(json['lat_used']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wallet_id': serializer.toJson<int?>(wallet_id),
      'category_id': serializer.toJson<int?>(category_id),
      'title': serializer.toJson<String>(title),
      'barcode_data': serializer.toJson<String>(barcode_data),
      'barcode_type': serializer.toJson<String>(barcode_type),
      'color': serializer.toJson<String?>(color),
      'is_favorite': serializer.toJson<bool>(is_favorite),
      'lat_used': serializer.toJson<DateTime?>(lat_used),
    };
  }

  CardEntry copyWith({
    int? id,
    Value<int?> wallet_id = const Value.absent(),
    Value<int?> category_id = const Value.absent(),
    String? title,
    String? barcode_data,
    String? barcode_type,
    Value<String?> color = const Value.absent(),
    bool? is_favorite,
    Value<DateTime?> lat_used = const Value.absent(),
  }) => CardEntry(
    id: id ?? this.id,
    wallet_id: wallet_id.present ? wallet_id.value : this.wallet_id,
    category_id: category_id.present ? category_id.value : this.category_id,
    title: title ?? this.title,
    barcode_data: barcode_data ?? this.barcode_data,
    barcode_type: barcode_type ?? this.barcode_type,
    color: color.present ? color.value : this.color,
    is_favorite: is_favorite ?? this.is_favorite,
    lat_used: lat_used.present ? lat_used.value : this.lat_used,
  );
  CardEntry copyWithCompanion(CardsCompanion data) {
    return CardEntry(
      id: data.id.present ? data.id.value : this.id,
      wallet_id: data.wallet_id.present ? data.wallet_id.value : this.wallet_id,
      category_id: data.category_id.present
          ? data.category_id.value
          : this.category_id,
      title: data.title.present ? data.title.value : this.title,
      barcode_data: data.barcode_data.present
          ? data.barcode_data.value
          : this.barcode_data,
      barcode_type: data.barcode_type.present
          ? data.barcode_type.value
          : this.barcode_type,
      color: data.color.present ? data.color.value : this.color,
      is_favorite: data.is_favorite.present
          ? data.is_favorite.value
          : this.is_favorite,
      lat_used: data.lat_used.present ? data.lat_used.value : this.lat_used,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardEntry(')
          ..write('id: $id, ')
          ..write('wallet_id: $wallet_id, ')
          ..write('category_id: $category_id, ')
          ..write('title: $title, ')
          ..write('barcode_data: $barcode_data, ')
          ..write('barcode_type: $barcode_type, ')
          ..write('color: $color, ')
          ..write('is_favorite: $is_favorite, ')
          ..write('lat_used: $lat_used')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    wallet_id,
    category_id,
    title,
    barcode_data,
    barcode_type,
    color,
    is_favorite,
    lat_used,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardEntry &&
          other.id == this.id &&
          other.wallet_id == this.wallet_id &&
          other.category_id == this.category_id &&
          other.title == this.title &&
          other.barcode_data == this.barcode_data &&
          other.barcode_type == this.barcode_type &&
          other.color == this.color &&
          other.is_favorite == this.is_favorite &&
          other.lat_used == this.lat_used);
}

class CardsCompanion extends UpdateCompanion<CardEntry> {
  final Value<int> id;
  final Value<int?> wallet_id;
  final Value<int?> category_id;
  final Value<String> title;
  final Value<String> barcode_data;
  final Value<String> barcode_type;
  final Value<String?> color;
  final Value<bool> is_favorite;
  final Value<DateTime?> lat_used;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.wallet_id = const Value.absent(),
    this.category_id = const Value.absent(),
    this.title = const Value.absent(),
    this.barcode_data = const Value.absent(),
    this.barcode_type = const Value.absent(),
    this.color = const Value.absent(),
    this.is_favorite = const Value.absent(),
    this.lat_used = const Value.absent(),
  });
  CardsCompanion.insert({
    this.id = const Value.absent(),
    this.wallet_id = const Value.absent(),
    this.category_id = const Value.absent(),
    required String title,
    required String barcode_data,
    required String barcode_type,
    this.color = const Value.absent(),
    this.is_favorite = const Value.absent(),
    this.lat_used = const Value.absent(),
  }) : title = Value(title),
       barcode_data = Value(barcode_data),
       barcode_type = Value(barcode_type);
  static Insertable<CardEntry> custom({
    Expression<int>? id,
    Expression<int>? wallet_id,
    Expression<int>? category_id,
    Expression<String>? title,
    Expression<String>? barcode_data,
    Expression<String>? barcode_type,
    Expression<String>? color,
    Expression<bool>? is_favorite,
    Expression<DateTime>? lat_used,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wallet_id != null) 'wallet_id': wallet_id,
      if (category_id != null) 'category_id': category_id,
      if (title != null) 'title': title,
      if (barcode_data != null) 'barcode_data': barcode_data,
      if (barcode_type != null) 'barcode_type': barcode_type,
      if (color != null) 'color': color,
      if (is_favorite != null) 'is_favorite': is_favorite,
      if (lat_used != null) 'lat_used': lat_used,
    });
  }

  CardsCompanion copyWith({
    Value<int>? id,
    Value<int?>? wallet_id,
    Value<int?>? category_id,
    Value<String>? title,
    Value<String>? barcode_data,
    Value<String>? barcode_type,
    Value<String?>? color,
    Value<bool>? is_favorite,
    Value<DateTime?>? lat_used,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      wallet_id: wallet_id ?? this.wallet_id,
      category_id: category_id ?? this.category_id,
      title: title ?? this.title,
      barcode_data: barcode_data ?? this.barcode_data,
      barcode_type: barcode_type ?? this.barcode_type,
      color: color ?? this.color,
      is_favorite: is_favorite ?? this.is_favorite,
      lat_used: lat_used ?? this.lat_used,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wallet_id.present) {
      map['wallet_id'] = Variable<int>(wallet_id.value);
    }
    if (category_id.present) {
      map['category_id'] = Variable<int>(category_id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (barcode_data.present) {
      map['barcode_data'] = Variable<String>(barcode_data.value);
    }
    if (barcode_type.present) {
      map['barcode_type'] = Variable<String>(barcode_type.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (is_favorite.present) {
      map['is_favorite'] = Variable<bool>(is_favorite.value);
    }
    if (lat_used.present) {
      map['lat_used'] = Variable<DateTime>(lat_used.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('wallet_id: $wallet_id, ')
          ..write('category_id: $category_id, ')
          ..write('title: $title, ')
          ..write('barcode_data: $barcode_data, ')
          ..write('barcode_type: $barcode_type, ')
          ..write('color: $color, ')
          ..write('is_favorite: $is_favorite, ')
          ..write('lat_used: $lat_used')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WalletsTable wallets = $WalletsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $CardsTable cards = $CardsTable(this);
  late final WalletsDao walletsDao = WalletsDao(this as AppDatabase);
  late final CardsDao cardsDao = CardsDao(this as AppDatabase);
  late final CategoriesDao categoriesDao = CategoriesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    wallets,
    categories,
    cards,
  ];
}

typedef $$WalletsTableCreateCompanionBuilder =
    WalletsCompanion Function({
      Value<int> id,
      required String name,
      required String color,
    });
typedef $$WalletsTableUpdateCompanionBuilder =
    WalletsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> color,
    });

final class $$WalletsTableReferences
    extends BaseReferences<_$AppDatabase, $WalletsTable, Wallet> {
  $$WalletsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardsTable, List<CardEntry>> _cardsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cards,
    aliasName: $_aliasNameGenerator(db.wallets.id, db.cards.wallet_id),
  );

  $$CardsTableProcessedTableManager get cardsRefs {
    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.wallet_id.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WalletsTableFilterComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cardsRefs(
    Expression<bool> Function($$CardsTableFilterComposer f) f,
  ) {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.wallet_id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WalletsTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  Expression<T> cardsRefs<T extends Object>(
    Expression<T> Function($$CardsTableAnnotationComposer a) f,
  ) {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.wallet_id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WalletsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletsTable,
          Wallet,
          $$WalletsTableFilterComposer,
          $$WalletsTableOrderingComposer,
          $$WalletsTableAnnotationComposer,
          $$WalletsTableCreateCompanionBuilder,
          $$WalletsTableUpdateCompanionBuilder,
          (Wallet, $$WalletsTableReferences),
          Wallet,
          PrefetchHooks Function({bool cardsRefs})
        > {
  $$WalletsTableTableManager(_$AppDatabase db, $WalletsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> color = const Value.absent(),
              }) => WalletsCompanion(id: id, name: name, color: color),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String color,
              }) => WalletsCompanion.insert(id: id, name: name, color: color),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WalletsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cardsRefs) db.cards],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardsRefs)
                    await $_getPrefetchedData<Wallet, $WalletsTable, CardEntry>(
                      currentTable: table,
                      referencedTable: $$WalletsTableReferences._cardsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$WalletsTableReferences(db, table, p0).cardsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.wallet_id == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WalletsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletsTable,
      Wallet,
      $$WalletsTableFilterComposer,
      $$WalletsTableOrderingComposer,
      $$WalletsTableAnnotationComposer,
      $$WalletsTableCreateCompanionBuilder,
      $$WalletsTableUpdateCompanionBuilder,
      (Wallet, $$WalletsTableReferences),
      Wallet,
      PrefetchHooks Function({bool cardsRefs})
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String system_tag,
      required String icon_name,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> system_tag,
      Value<String> icon_name,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardsTable, List<CardEntry>> _cardsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cards,
    aliasName: $_aliasNameGenerator(db.categories.id, db.cards.category_id),
  );

  $$CardsTableProcessedTableManager get cardsRefs {
    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.category_id.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get system_tag => $composableBuilder(
    column: $table.system_tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon_name => $composableBuilder(
    column: $table.icon_name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cardsRefs(
    Expression<bool> Function($$CardsTableFilterComposer f) f,
  ) {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.category_id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get system_tag => $composableBuilder(
    column: $table.system_tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon_name => $composableBuilder(
    column: $table.icon_name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get system_tag => $composableBuilder(
    column: $table.system_tag,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon_name =>
      $composableBuilder(column: $table.icon_name, builder: (column) => column);

  Expression<T> cardsRefs<T extends Object>(
    Expression<T> Function($$CardsTableAnnotationComposer a) f,
  ) {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.category_id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool cardsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> system_tag = const Value.absent(),
                Value<String> icon_name = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                system_tag: system_tag,
                icon_name: icon_name,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String system_tag,
                required String icon_name,
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                system_tag: system_tag,
                icon_name: icon_name,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cardsRefs) db.cards],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardsRefs)
                    await $_getPrefetchedData<
                      Category,
                      $CategoriesTable,
                      CardEntry
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._cardsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(db, table, p0).cardsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.category_id == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool cardsRefs})
    >;
typedef $$CardsTableCreateCompanionBuilder =
    CardsCompanion Function({
      Value<int> id,
      Value<int?> wallet_id,
      Value<int?> category_id,
      required String title,
      required String barcode_data,
      required String barcode_type,
      Value<String?> color,
      Value<bool> is_favorite,
      Value<DateTime?> lat_used,
    });
typedef $$CardsTableUpdateCompanionBuilder =
    CardsCompanion Function({
      Value<int> id,
      Value<int?> wallet_id,
      Value<int?> category_id,
      Value<String> title,
      Value<String> barcode_data,
      Value<String> barcode_type,
      Value<String?> color,
      Value<bool> is_favorite,
      Value<DateTime?> lat_used,
    });

final class $$CardsTableReferences
    extends BaseReferences<_$AppDatabase, $CardsTable, CardEntry> {
  $$CardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WalletsTable _wallet_idTable(_$AppDatabase db) => db.wallets
      .createAlias($_aliasNameGenerator(db.cards.wallet_id, db.wallets.id));

  $$WalletsTableProcessedTableManager? get wallet_id {
    final $_column = $_itemColumn<int>('wallet_id');
    if ($_column == null) return null;
    final manager = $$WalletsTableTableManager(
      $_db,
      $_db.wallets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wallet_idTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _category_idTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.cards.category_id, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get category_id {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_category_idTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CardsTableFilterComposer extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode_data => $composableBuilder(
    column: $table.barcode_data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode_type => $composableBuilder(
    column: $table.barcode_type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get is_favorite => $composableBuilder(
    column: $table.is_favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lat_used => $composableBuilder(
    column: $table.lat_used,
    builder: (column) => ColumnFilters(column),
  );

  $$WalletsTableFilterComposer get wallet_id {
    final $$WalletsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wallet_id,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableFilterComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get category_id {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.category_id,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode_data => $composableBuilder(
    column: $table.barcode_data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode_type => $composableBuilder(
    column: $table.barcode_type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get is_favorite => $composableBuilder(
    column: $table.is_favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lat_used => $composableBuilder(
    column: $table.lat_used,
    builder: (column) => ColumnOrderings(column),
  );

  $$WalletsTableOrderingComposer get wallet_id {
    final $$WalletsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wallet_id,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableOrderingComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get category_id {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.category_id,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get barcode_data => $composableBuilder(
    column: $table.barcode_data,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode_type => $composableBuilder(
    column: $table.barcode_type,
    builder: (column) => column,
  );

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get is_favorite => $composableBuilder(
    column: $table.is_favorite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lat_used =>
      $composableBuilder(column: $table.lat_used, builder: (column) => column);

  $$WalletsTableAnnotationComposer get wallet_id {
    final $$WalletsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wallet_id,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableAnnotationComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get category_id {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.category_id,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardsTable,
          CardEntry,
          $$CardsTableFilterComposer,
          $$CardsTableOrderingComposer,
          $$CardsTableAnnotationComposer,
          $$CardsTableCreateCompanionBuilder,
          $$CardsTableUpdateCompanionBuilder,
          (CardEntry, $$CardsTableReferences),
          CardEntry,
          PrefetchHooks Function({bool wallet_id, bool category_id})
        > {
  $$CardsTableTableManager(_$AppDatabase db, $CardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> wallet_id = const Value.absent(),
                Value<int?> category_id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> barcode_data = const Value.absent(),
                Value<String> barcode_type = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> is_favorite = const Value.absent(),
                Value<DateTime?> lat_used = const Value.absent(),
              }) => CardsCompanion(
                id: id,
                wallet_id: wallet_id,
                category_id: category_id,
                title: title,
                barcode_data: barcode_data,
                barcode_type: barcode_type,
                color: color,
                is_favorite: is_favorite,
                lat_used: lat_used,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> wallet_id = const Value.absent(),
                Value<int?> category_id = const Value.absent(),
                required String title,
                required String barcode_data,
                required String barcode_type,
                Value<String?> color = const Value.absent(),
                Value<bool> is_favorite = const Value.absent(),
                Value<DateTime?> lat_used = const Value.absent(),
              }) => CardsCompanion.insert(
                id: id,
                wallet_id: wallet_id,
                category_id: category_id,
                title: title,
                barcode_data: barcode_data,
                barcode_type: barcode_type,
                color: color,
                is_favorite: is_favorite,
                lat_used: lat_used,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$CardsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({wallet_id = false, category_id = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wallet_id) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wallet_id,
                                referencedTable: $$CardsTableReferences
                                    ._wallet_idTable(db),
                                referencedColumn: $$CardsTableReferences
                                    ._wallet_idTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (category_id) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.category_id,
                                referencedTable: $$CardsTableReferences
                                    ._category_idTable(db),
                                referencedColumn: $$CardsTableReferences
                                    ._category_idTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardsTable,
      CardEntry,
      $$CardsTableFilterComposer,
      $$CardsTableOrderingComposer,
      $$CardsTableAnnotationComposer,
      $$CardsTableCreateCompanionBuilder,
      $$CardsTableUpdateCompanionBuilder,
      (CardEntry, $$CardsTableReferences),
      CardEntry,
      PrefetchHooks Function({bool wallet_id, bool category_id})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WalletsTableTableManager get wallets =>
      $$WalletsTableTableManager(_db, _db.wallets);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
}
