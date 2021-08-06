import 'package:flutter_test/flutter_test.dart';

import 'model.dart';

const companyData = {
  'name': 'Company1',
  'machines': machinesData,
};

const machinesData = [
  {'name': 'Machine A', 'capacity': 2},
  {'name': 'Machine B', 'capacity': 3},
  {'name': 'Machine C', 'capacity': 5}
];

void main() {
  group('Entity Test =>', () {
    final company = Company();

    test('Company is empty', () {
      expect(company.isEmpty, true);
    });
    test('Machine is empty', () {
      expect(company.machines.isEmpty, true);
    });
    test('Company is loaded', () {
      company.load(companyData);
      expect(company.isNotEmpty, true);
    });
    test('Company.time is null', () {
      expect(company.time.valueIsNull, true);
    });
    test('Company.capacity() == 10', () {
      expect(company.capacity(), 10);
    });
    test('Company.kpi() == 0', () {
      expect(company.kpi(), 0);
    });
    test('Machine.length == 3', () {
      expect(company.machines.length, 3);
    });
    test('Machine children has parent', () {
      expect(
          company.machines
              .every((element) => element.parent == company.machines),
          true);
    });
    test('Settings is not null', () {
      expect(company.settings.valueIsNotNull, true);
    });
    test('Settings has parent', () {
      expect(company.settings().parent == company.settings, true);
    });
    test('Settings.minCapacity default 10', () {
      expect(company.settings().minCapacity(), 10);
    });
    test('Settings.minCapacity changed 30', () {
      company.settings().minCapacity(30);
      expect(company.settings().minCapacity(), 30);
    });
    test('PlanQuality is null', () {
      expect(company.planQuality.valueIsNull, true);
    });
    test('PlanQuality is not null', () {
      company.planQuality(PlanQuality());
      expect(company.planQuality.valueIsNotNull, true);
    });
    test('PlanQuality has parent', () {
      expect(company.planQuality().parent == company.planQuality, true);
    });
    test('Company.Reset()', () {
      company.reset();
      expect(company.isEmpty, true);
    });
    test('Machine empty', () {
      expect(company.machines.length, 0);
    });
    test('Settings back to default', () {
      expect(company.settings().minCapacity(), 10);
    });
    test('PlanQuality is cleared', () {
      expect(company.planQuality.valueIsNull, true);
    });
  });
}
