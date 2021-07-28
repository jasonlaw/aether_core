import 'package:aether_core/aether_core.dart';

class Company extends Entity {
  late final Field<DateTime> name = this.field('name');
  late final Field<DateTime> time = this.field('time');
  late final Field<int> capacity = this.field('capacity');
  late final Field<double> kpi = this.field('kpi');
  late final ListField<Machine> machines = this.fieldList('machines');
  late final Field<Settings> settings = this.field('settings');
  late final Field<PlanQuality> planQuality = this.field('planQuality');

  Company() {
    print('Company constructor');
    this.capacity.computed(
      bindings: [machines],
      compute: () => machines().fold(0, (p, e) => p! + e.capacity()),
    );
    this.machines.register(() => Machine());
    this.settings.register(() => Settings(), auto: true);
    print('End of Company constructor');
  }
}

class Machine extends Entity {
  late final Field<String> name = this.field('name');
  late final Field<int> capacity = this.field('capacity');
}

class Settings extends Entity {
  late final Field<int> minCapacity =
      this.field('minCapacity', defaultValue: 10);
}

class PlanQuality extends Entity {}
