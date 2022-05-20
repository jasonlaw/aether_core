import 'package:aether_core/aether_core.dart';
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
    test('Company is reloaded again', () {
      company.load(companyData);
      expect(company.isNotEmpty, true);
    });
    test('Field Rx', () async {
      //final count = 0.obs;
      company.count(0);
      var result = -1;
      ever<Field<int>>(company.count.rx, (value) {
        result = value();
      });
      company.count(company.count() + 1);
      await Future.delayed(Duration.zero);
      expect(result, 1);
      company.count(company.count() + 1);
      await Future.delayed(Duration.zero);
      expect(result, 2);
      company.count(company.count() + 1);
      await Future.delayed(Duration.zero);
      expect(result, 3);
    });

    test('Entity Rx', () async {
      final firstMachine = company.machines.first;

      var capacity = firstMachine.capacity();
      expect(capacity, 2, reason: 'Machine capacity not matched.');
      var totalCapacity = company.capacity();
      expect(totalCapacity, 10);

      ever<Field<int>>(firstMachine.capacity.rx, (value) {
        capacity = value();
      });

      ever<Entity>(company.rx, (value) {
        totalCapacity = (value as Company).capacity();
      });

      firstMachine.capacity(11);
      await Future.delayed(Duration.zero);
      expect(capacity, 11);
      expect(totalCapacity, 19);
    });

    test('Entity identity', () {
      final identity = CredentialIdentity();
      identity.signIn(
        '123',
        'jasonlaw',
        'Jason Law',
        'jason.cclaw@gmail.com',
        roles: 'SystemAdmin,ABC, CDE  ,ABC, ',
      );

      final roles = identity
          .roles()
          .split(',')
          .map((e) => e.trim())
          .where((element) => element.isNotEmpty)
          .toSet();
      expect(3, roles.length, reason: roles.toString());
      expect(true, identity.isAuthenticated, reason: 'isAuthenticated');
      expect(true, identity.hasRoles({'SystemAdmin'}),
          reason: 'Has SystemAdmin role');
      expect(true, identity.hasRoles({'CDE'}), reason: 'Has CDE role');
      expect(true, identity.hasRoles({'ABC', 'CDE'}),
          reason: 'Has ABC and CDE role');
      expect(false, identity.hasRoles({'ZZZ', 'CDE'}),
          reason: 'Has ZZZ and CDE role');
      expect(true, identity.anyRoles({'ZZZ', 'CDE'}),
          reason: 'Has ZZZ or CDE role');

      identity.reset();
      expect(false, identity.hasRoles({'SystemAdmin'}),
          reason: 'No more SystemAdmin role');
      expect(false, identity.isAuthenticated, reason: 'No more authenticated');
    });
  });
}
