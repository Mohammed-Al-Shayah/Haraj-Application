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
  Switch,
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

enum BuildingAge {
  lessThan5,
  between5And15,
  moreThan15;

  @override
  String toString() {
    switch (this) {
      case BuildingAge.lessThan5:
        return 'building_age_lessThan5'.tr();
      case BuildingAge.between5And15:
        return 'building_age_between5And15'.tr();
      case BuildingAge.moreThan15:
        return 'building_age_moreThan15'.tr();
    }
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

enum InternalFeature {
  garden,
  telephoneLine,
  internetLine,
  builtInDishwasher,
  ceramicTiles;

  @override
  String toString() {
    switch (this) {
      case InternalFeature.garden:
        return 'garden_feature'.tr();
      case InternalFeature.telephoneLine:
        return 'telephone_line'.tr();
      case InternalFeature.internetLine:
        return 'internet_line'.tr();
      case InternalFeature.builtInDishwasher:
        return 'built_in_dishwasher'.tr();
      case InternalFeature.ceramicTiles:
        return 'ceramic_tiles'.tr();
    }
  }
}

enum NearbyPlace {
  airport,
  beach,
  downtown,
  hospital,
  amusement,
  school,
  supermarket,
  mosque,
  mall,
  clothingCenter,
  restaurant,
  cafe,
  fireStation,
  policeStation;

  @override
  String toString() {
    switch (this) {
      case NearbyPlace.airport:
        return 'near_airport'.tr();
      case NearbyPlace.beach:
        return 'near_beach'.tr();
      case NearbyPlace.downtown:
        return 'near_downtown'.tr();
      case NearbyPlace.hospital:
        return 'near_hospital'.tr();
      case NearbyPlace.amusement:
        return 'near_amusement'.tr();
      case NearbyPlace.school:
        return 'near_school'.tr();
      case NearbyPlace.supermarket:
        return 'near_supermarket'.tr();
      case NearbyPlace.mosque:
        return 'near_mosque'.tr();
      case NearbyPlace.mall:
        return 'near_mall'.tr();
      case NearbyPlace.clothingCenter:
        return 'near_clothing_center'.tr();
      case NearbyPlace.restaurant:
        return 'near_restaurant'.tr();
      case NearbyPlace.cafe:
        return 'near_cafe'.tr();
      case NearbyPlace.fireStation:
        return 'near_fire_station'.tr();
      case NearbyPlace.policeStation:
        return 'near_police_station'.tr();
    }
  }
}

enum CurrencyOption {
  rialYemeni,
  dollarUsd,
  poundEgp,
  euro;

  @override
  String toString() {
    switch (this) {
      case CurrencyOption.rialYemeni:
        return 'currency_rial_yemeni'.tr();
      case CurrencyOption.dollarUsd:
        return 'currency_dollar_usd'.tr();
      case CurrencyOption.poundEgp:
        return 'currency_pound_egp'.tr();
      case CurrencyOption.euro:
        return 'currency_euro'.tr();
    }
  }
}

enum ShopOpenings {
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  moreThanNine;

  @override
  String toString() {
    switch (this) {
      case ShopOpenings.one:
        return 'shop_openings.one'.tr();
      case ShopOpenings.two:
        return 'shop_openings.two'.tr();
      case ShopOpenings.three:
        return 'shop_openings.three'.tr();
      case ShopOpenings.four:
        return 'shop_openings.four'.tr();
      case ShopOpenings.five:
        return 'shop_openings.five'.tr();
      case ShopOpenings.six:
        return 'shop_openings.six'.tr();
      case ShopOpenings.seven:
        return 'shop_openings.seven'.tr();
      case ShopOpenings.eight:
        return 'shop_openings.eight'.tr();
      case ShopOpenings.nine:
        return 'shop_openings.nine'.tr();
      case ShopOpenings.moreThanNine:
        return 'shop_openings.more_than_nine'.tr();
    }
  }
}
