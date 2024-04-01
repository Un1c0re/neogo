part of 'package:diplom/data/moor_db.dart';

@UseDao(tables: [Users, SymptomsTypes, SymptomsNames, SymptomsValues])
class SymptomsNamesDao extends DatabaseAccessor<AppDatabase>
    with _$SymptomsNamesDaoMixin {
  final AppDatabase db;

  SymptomsNamesDao(this.db) : super(db);

  Future<void> initSymptomsNames() async {
    final query = select(symptomsNames)..limit(1);
    final List<SymptomsName> names = await query.get();
    final bool doNamesExist = names.isNotEmpty;

    if(doNamesExist) return;

    List<String> boolSymptomsNames  = dotenv.env['BOOL_SYMPTOMS_NAMES']!.split(',');
    List<String> gradeSymptomsNames = dotenv.env['GRADE_SYMPTOMS_NAMES']!.split(',');
    List<String> numSymptomsNames   = dotenv.env['NUM_SYMPTOMS_NAMES']!.split(',');

    for(int i = 0; i < boolSymptomsNames.length; i++) {
      await into(symptomsNames).insert(
        SymptomsNamesCompanion(
          type_id: const Value(1),
          name: Value(boolSymptomsNames[i])
        )
      );
    }

    for(int i = 0; i < gradeSymptomsNames.length; i++) {
      await into(symptomsNames).insert(
        SymptomsNamesCompanion(
          type_id: const Value(2),
          name: Value(gradeSymptomsNames[i])
        )
      );
    }
    for(int i = 0; i < numSymptomsNames.length; i++) {
      await into(symptomsNames).insert(
        SymptomsNamesCompanion(
          type_id: const Value(3),
          name: Value(numSymptomsNames[i])
        )
      );
    }
  }

  Future<void> addSymptomName(String newName) async {
    await into(symptomsNames).insert(
      SymptomsNamesCompanion(
        type_id: const Value(4),
        name: Value(newName)
      )
    );
  }

  Future<void> deleteSymptomName(String symptomName) async {
    await (delete(symptomsNames)
      ..where((tbl) => tbl.name.equals(symptomName)))
      .go();
  }
}
