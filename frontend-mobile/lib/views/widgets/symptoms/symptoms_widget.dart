import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplom/services/database_service.dart';
import 'package:diplom/models/symptoms_models.dart';

import 'package:diplom/utils/app_colors.dart';
import 'package:diplom/utils/app_style.dart';
import 'package:diplom/utils/app_widgets.dart';
import 'package:diplom/utils/constants.dart';

import 'package:diplom/views/screens/symptoms/add_symptom_screen.dart';
import 'package:diplom/views/widgets/symptoms/bool_symptom_widget.dart';
import 'package:diplom/views/widgets/symptoms/grade_symptom_widget.dart';

class SymptomsWidget extends StatefulWidget {
  const SymptomsWidget({super.key});

  @override
  State<SymptomsWidget> createState() => _SymptomsWidgetState();
}

class _SymptomsWidgetState extends State<SymptomsWidget> {
  final _notesInputController = TextEditingController();
  final notesInputDecoration = AppStyleTextFields.sharedDecoration;
  DateTime selectedDate = DateTime.now();

  void updateData() {
    setState(() {
      // Это заставит виджет перерисоваться
    });
  }

  // Calendar
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      cancelText: 'Отменить',
      confirmText: 'Подтвердить',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryColor, // Цвет выбранной даты
            colorScheme: const ColorScheme.light(
                primary: AppColors.primaryColor), // Цветовая схема
            buttonTheme: const ButtonThemeData(
                textTheme: ButtonTextTheme.primary), // Тема кнопок
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _addSymptom() => Get.to(() => AddSymptomScreen());

  @override
  Widget build(BuildContext context) {
    final DatabaseService _databaseService = Get.find();

    Future<List<SymptomDetails>> getSymptomData() async {
      DateTime date =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      List<SymptomDetails> symptomDetails =
          await _databaseService.database.symptomsDao.getSymptomsDetails(date);

      if (symptomDetails.isEmpty) {
        await _databaseService.database.symptomsDao
            .initializeSymptomsValues(date);
        symptomDetails = await _databaseService.database.symptomsDao
            .getSymptomsDetails(date);
      }

      return symptomDetails;
    }

    return Scaffold(
        appBar: AppBar(
          title: Container(
            constraints: const BoxConstraints(
              maxWidth: 150,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: const ButtonStyle(
                      padding: MaterialStatePropertyAll(EdgeInsets.zero),
                      foregroundColor: MaterialStatePropertyAll(
                          Color.fromARGB(255, 255, 255, 255)),
                    ),
                    onPressed: () => _selectDate(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_outlined),
                        Text(
                          selectedDate.toIso8601String().substring(0, 10),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0),
            ),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder(
                    future: getSymptomData(),
                    builder: ((context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final List<SymptomDetails> symptoms = snapshot.data!;
                        final List<SymptomDetails> gradeSymptoms = [];
                        final List<SymptomDetails> boolSymptoms = [];

                        for (int i = 0; i < symptoms.length; i++) {
                          if (symptoms[i].symptomType == 'grade') {
                            gradeSymptoms.add(symptoms[i]);
                          } else if (symptoms[i].symptomType == 'bool') {
                            boolSymptoms.add(symptoms[i]);
                          }
                        }

                        final List<Widget> combinedSymptomsWidgets = [];
                        int gradeIndex = 0;
                        int boolIndex = 0;

                        while (gradeIndex < gradeSymptoms.length ||
                            boolIndex < boolSymptoms.length) {
                          // Добавляем GradeSymptom, если он доступен
                          if (gradeIndex < gradeSymptoms.length) {
                            combinedSymptomsWidgets.add(
                              GradeSymptomWidget(
                                symptomID: gradeSymptoms[gradeIndex].id,
                                label: gradeSymptoms[gradeIndex].symptomName,
                                symptomCurrentValue:
                                    gradeSymptoms[gradeIndex].symptomValue,
                                onUpdate: updateData,
                              ),
                            );
                            gradeIndex++;
                          }
                          combinedSymptomsWidgets.add(SizedBox(height: 20));
                          // Добавляем две строки с BoolSymptomWidget, если они доступны
                          List<Widget> rowWidgets = [];
                          for (int i = 0;
                              i < 4 && boolIndex < boolSymptoms.length;
                              i++, boolIndex++) {
                            rowWidgets.add(
                              BoolSymptomWidget(
                                symptomID: boolSymptoms[boolIndex].id,
                                label: boolSymptoms[boolIndex].symptomName,
                                value: boolSymptoms[boolIndex].symptomValue,
                              ),
                            );
                            if ((i + 1) % 2 == 0 ||
                                boolIndex == boolSymptoms.length) {
                              // Каждые два BoolSymptomWidget добавляем в Row и сбрасываем rowWidgets
                              combinedSymptomsWidgets.add(Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.from(rowWidgets)));
                              rowWidgets.clear();
                            }
                            combinedSymptomsWidgets.add(SizedBox(height: 20));
                          }
                        }

                        return ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth:
                                  DeviceScreenConstants.screenWidth * 0.9),
                          child: Column(children: combinedSymptomsWidgets),
                        );
                      }
                    }),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: DeviceScreenConstants.screenWidth * 0.9,
                        maxHeight: DeviceScreenConstants.screenHeight * 0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: AppButtonStyle.filledRoundedButton,
                            onPressed: _addSymptom,
                            child: const Text('Добавить симптом'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 200,
                    ),
                    child: AppStyleCard(
                      backgroundColor: Colors.white,
                      child: Column(
                        children: [
                          const Text(
                            'Ваша заметка',
                            style: TextStyle(fontSize: 20),
                          ),
                          TextField(
                            maxLines: 5,
                            decoration: notesInputDecoration,
                            cursorColor: AppColors.activeColor,
                            controller: _notesInputController,
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }
}
