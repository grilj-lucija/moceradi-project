enum MealSlot { breakfast, lunch, dinner, snack }

extension MealSlotX on MealSlot {
  String get wireValue => name;

  String get label => switch (this) {
        MealSlot.breakfast => 'Breakfast',
        MealSlot.lunch => 'Lunch',
        MealSlot.dinner => 'Dinner',
        MealSlot.snack => 'Snack',
      };

  static MealSlot fromWire(String? value) {
    for (final v in MealSlot.values) {
      if (v.name == value) return v;
    }
    return MealSlot.snack;
  }
}
