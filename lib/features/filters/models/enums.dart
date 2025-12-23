// ignore_for_file: constant_identifier_names

import 'package:localize_and_translate/localize_and_translate.dart';

enum AdState {
  published,
  unpublished;

  @override
  toString() {
    return name.tr();
  }
}

enum AdType {
  real_estates,
  vehicles;

  @override
  toString() {
    return name.tr();
  }
}

enum VehicleType {
  truck,
  big_truck,
  car,
  motor;

  @override
  toString() {
    return name.tr();
  }
}

enum AdCategory {
  sell,
  adSwitch,
  rent;

  @override
  toString() {
    return name.tr();
  }
}

enum AdElementState {
  New,
  used;

  @override
  toString() {
    return name.tr();
  }
}

enum PaySystem {
  cash,
  parts;

  @override
  toString() {
    return name.tr();
  }
}

enum RealEstateType {
  apartments,
  buildings,
  houses,
  lands,
  villas;

  @override
  toString() {
    return name.tr();
  }
}

enum RealEstateFurnitureType {
  yes,
  no,
  semi_furnished;

  @override
  toString() {
    return name.tr();
  }
}

enum RealEstateBuilding {
  busnies,
  residential;

  @override
  toString() {
    return name.tr();
  }
}

enum RealEstateFinishing {
  full_finishing,
  part_finishing,
  without_finishing;

  @override
  toString() {
    return name.tr();
  }
}

enum GroundSystem {
  residential,
  busnies,
  industrial,
  agricultural;

  @override
  toString() {
    return name.tr();
  }
}

enum FuelType {
  gasoline,
  diesel,
  gas,
  hybrid,
  electricity;

  @override
  toString() {
    return name.tr();
  }
}

enum JerType {
  automatic,
  manual;

  @override
  toString() {
    return name.tr();
  }
}
