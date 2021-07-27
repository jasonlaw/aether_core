import 'package:aether_core/aether_core.dart';

class Company extends Entity {
  late final EntityField<DateTime> name = this.field('name');
  late final EntityField<DateTime> time = this.field('time');
  late final EntityField<int> capacity = this.field('capacity');
  late final EntityField<double> kpi = this.field('kpi');
  late final EntityListField<Machine> machines = this.fieldList('machines');
  late final EntityField<Settings> settings = this.field('settings');

  Company() {
    print('Company constructor');
    this.capacity.computed(
      bindings: [machines],
      compute: () => machines().fold(0, (p, e) => p! + e.capacity()),
    );
    this.machines.onLoading(() => Machine());
    print('End of Company constructor');
  }
}

class Machine extends Entity {
  late final EntityField<String> name = this.field('name');
  late final EntityField<int> capacity = this.field('capacity');
}

class Settings extends Entity {
  late final EntityField<int> minCapacity =
      this.field('minCapacity', defaultValue: 10);
}
