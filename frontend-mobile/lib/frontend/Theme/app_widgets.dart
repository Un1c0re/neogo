import 'package:diplom/frontend/Theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppStyleCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  
  const AppStyleCard({
    super.key, 
    required this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
      color: backgroundColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 2,
          offset: const Offset(0, 2),
        ),
    ],
      borderRadius: const BorderRadius.all(
        Radius.circular(10),
      ),
    ),

    child: SizedBox(
      height: double.maxFinite,
      width: double.maxFinite,

      child: Padding(
        padding: const EdgeInsets.all(8.0),

        child: child
        ),
      ),
    );
  }
}


class ApppStyleChip extends StatefulWidget {
  final String label;

  const ApppStyleChip({
    super.key, 
    required this.label,
  });

  @override
  State<ApppStyleChip> createState() => _ApppStyleChipState();
}

class _ApppStyleChipState extends State<ApppStyleChip> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 200,
      ),
      child: Chip(
        // padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        label: Text(widget.label, maxLines: 3, softWrap: true),
        labelStyle: const TextStyle(
          fontSize: 18,
        ),
    
        shadowColor: Colors.black,
        elevation: 3,
    
        side: BorderSide.none,
    
        onDeleted: () {
          setState(() {
            _isSelected = !_isSelected;
          });
        },
        deleteIcon: _isSelected ? Icon(Icons.check) : Icon(Icons.add),
    
        backgroundColor: _isSelected ? AppColors.redColor : Colors.white,
      ),
    );
  }
}