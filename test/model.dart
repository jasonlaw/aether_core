import 'package:aether_core/aether_core.dart';
import 'package:flutter/foundation.dart';

class Company extends Entity {
  late final Field<DateTime> name = field('name');
  late final Field<DateTime> time = field('time');
  late final Field<int> capacity = field('capacity');
  late final Field<double> kpi = field('kpi');
  late final ListField<Machine> machines = fieldList('machines');
  late final Field<Settings> settings = field('settings');
  late final Field<PlanQuality> planQuality = field('planQuality');

  Company() {
    if (kDebugMode) {
      print('Company constructor');
    }
    capacity.computed(
      bindings: [machines],
      compute: () => machines.fold(0, (p, e) => p! + e.capacity()),
    );
    machines.register(() => Machine());
    settings.register(() => Settings(), auto: true);
    if (kDebugMode) {
      print('End of Company constructor');
    }
  }
}

class Machine extends Entity {
  late final Field<String> name = field('name');
  late final Field<int> capacity = field('capacity');
}

class Settings extends Entity {
  late final Field<int> minCapacity = field('minCapacity', defaultValue: 10);
}

class PlanQuality extends Entity {}
