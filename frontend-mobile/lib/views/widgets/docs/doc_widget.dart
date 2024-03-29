import 'package:diplom/models/docs_models.dart';
import 'package:diplom/services/database_service.dart';
import 'package:diplom/utils/app_colors.dart';
import 'package:diplom/utils/app_icons.dart';
import 'package:diplom/utils/app_style.dart';
import 'package:diplom/utils/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constants.dart';

class DocWidget extends StatelessWidget {
  final int docID;
  const DocWidget({
    super.key,
    required this.docID,
  });

  @override
  Widget build(BuildContext context) {
    final DatabaseService _databaseService = Get.find();

    Future<void> deleteDoc(docID) async {
      await _databaseService.database.docsDao.deleteDoc(docID: docID);
      Get.back();
      Get.snackbar(
        'Успешно!',
        'Документ удален',
        backgroundColor: Colors.tealAccent.withOpacity(0.4),
        colorText: Colors.teal.shade900,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
        animationDuration: const Duration(milliseconds: 500),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
            children: [
              SizedBox(
                height: DeviceScreenConstants.screenHeight * 0.75,
                child: AppStyleCard(
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: DocDataWidget(
                      docID: docID,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              ConstrainedBox(
                constraints:
                    const BoxConstraints(maxHeight: 100, maxWidth: 350),
                child: Column(children: [
                  ElevatedButton(
                    style: AppButtonStyle.filledRoundedButton,
                    onPressed: () {},
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(AppIcons.pen),
                        SizedBox(width: 20),
                        Text(
                          'Изменить',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: AppButtonStyle.outlinedRedRoundedButton,
                    onPressed: () => deleteDoc(docID),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error),
                        SizedBox(width: 20),
                        Text(
                          'Удалить',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DocDataWidget extends StatelessWidget {
  final int docID;

  const DocDataWidget({
    super.key,
    required this.docID,
  });

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = Get.find();

    Future<DocModel?> getDocument(id) async {
      return await databaseService.database.docsDao.getDoc(id);
    }

    return FutureBuilder(
        future: getDocument(docID),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final DocModel document = snapshot.data!;
            return SizedBox(
              height: DeviceScreenConstants.screenHeight * 0.5,
              width: double.maxFinite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.docName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    'тип документа',
                    style: TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Дата оформления документа:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    document.docDate.toString().substring(0, 10),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'Учреждение:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    document.docPlace,
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    'Примечания:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    document.docNotes,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  const _DocMiniature(),
                ],
              ),
            );
          }
        }
      ),
    );
  }
}

class _DocMiniature extends StatelessWidget {
  const _DocMiniature({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 70,
        maxWidth: 70,
      ),
      child: Stack(
        children: [
          const AppStyleCard(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.description_rounded,
              size: 40,
              color: AppColors.activeColor,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              overlayColor:
                  const MaterialStatePropertyAll(AppColors.overlayColor),
              splashColor: AppColors.splashColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
