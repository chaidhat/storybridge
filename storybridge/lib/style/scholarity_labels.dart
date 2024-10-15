import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/Storybridge.dart'; // Storybridge

import 'package:mooc/style/Storybridge_colors.dart' as Storybridge_color;
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;

class StorybridgeLabels extends StatelessWidget {
  final int? labelGroupId;
  final List<dynamic> selectedLabels;
  final bool canEdit;
  final Function(List<int> labelId)? onUpdate;

  // constructor
  const StorybridgeLabels({
    Key? key,
    this.labelGroupId,
    required this.selectedLabels,
    this.onUpdate,
    required this.canEdit,
  }) : super(key: key);

  Future<dynamic> _load() async {
    if (canEdit && labelGroupId != null) {
      Map<String, dynamic> data =
          await networking_api_service.getLabels(labelGroupId: labelGroupId!);
      return data["data"];
    }
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _load(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const StorybridgeBoxLoading(height: 40, width: 40);
          }
          return Row(
            children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(selectedLabels.length, (int i) {
                    return StorybridgeLabel(
                        label:
                            Uri.decodeComponent(selectedLabels[i]["labelName"]),
                        color: selectedLabels[i]["color"],
                        description: Uri.decodeComponent(
                            selectedLabels[i]["labelDescription"]));
                  })),
              const SizedBox(width: 10),
              (canEdit && labelGroupId != null && onUpdate != null)
                  ? PopupMenuButton(
                      tooltip: "",
                      // Callback that sets the selected popup menu item.
                      itemBuilder: (BuildContext context) {
                        return List.generate(snapshot.data.length, (int i) {
                          return PopupMenuItem(
                            onTap: () {
                              onUpdate!([snapshot.data[i]["labelId"]]);
                            },
                            child: StorybridgeLabel(
                                label: Uri.decodeComponent(
                                    snapshot.data[i]["labelName"]),
                                description: Uri.decodeComponent(
                                    snapshot.data[i]["labelDescription"]),
                                color: snapshot.data[i]["color"]),
                          );
                        });
                      },
                      child: StorybridgeIconButton(
                        icon: Icons.sell_outlined,
                        isEnabled: true,
                      ),
                    )
                  : Container(),
            ],
          );
        });
  }
}

class StorybridgeLabel extends StatelessWidget {
  final String label;
  final String description;
  final String color;
  final double targetContrastRatio = .2;
  // constructor
  const StorybridgeLabel(
      {Key? key,
      required this.label,
      required this.description,
      required this.color})
      : super(key: key);

  Color _getTextColor(Color color) {
    return Storybridge_color.getTextColor(color);
  }

  Color _getBackgroundColor(Color color) {
    return Storybridge_color.getBackgroundColor(color);
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    Color colorizedColor = HexColor(color);
    return Tooltip(
      message: description,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _getBackgroundColor(colorizedColor)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: IntrinsicWidth(
            child: StorybridgeTextBasic(label,
                style: TextStyle(
                    color: _getTextColor(colorizedColor),
                    fontSize: 14,
                    fontWeight: !isWhite(colorizedColor)
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ),
        ),
      ),
    );
  }
}
