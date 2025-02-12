import "package:desktop_updater/desktop_updater.dart";
import "package:desktop_updater/updater_controller.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

class UpdateDialogListener extends StatefulWidget {
  const UpdateDialogListener({
    super.key,
    required this.controller,
    this.backgroundColor,
    this.iconColor,
    this.shadowColor,
  });

  final DesktopUpdaterController controller;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? shadowColor;

  @override
  State<UpdateDialogListener> createState() => _UpdateDialogListenerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<DesktopUpdaterController>(
        "controller",
        controller,
      ),
    );
    properties.add(ColorProperty("backgroundColor", backgroundColor));
    properties.add(ColorProperty("iconColor", iconColor));
    properties.add(ColorProperty("shadowColor", shadowColor));
  }
}

class _UpdateDialogListenerState extends State<UpdateDialogListener> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        debugPrint("UpdateDialogListener: ${widget.controller.needUpdate}");
        if (((widget.controller.needUpdate) == false) ||
            (widget.controller.skipUpdate) ||
            widget.controller.isDownloading) {
          return const SizedBox();
        } else {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            showDialog(
              context: context,
              // barrierDismissible: controller.isMandatory == false,
              builder: (context) {
                return UpdateDialogWidget(
                  controller: widget.controller,
                  backgroundColor: widget.backgroundColor,
                  iconColor: widget.iconColor,
                  shadowColor: widget.shadowColor,
                );
              },
            );
          });
        }
        return const SizedBox();
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<DesktopUpdaterController>(
        "controller",
        widget.controller,
      ),
    );
    properties.add(ColorProperty("backgroundColor", widget.backgroundColor));
    properties.add(ColorProperty("iconColor", widget.iconColor));
    properties.add(ColorProperty("shadowColor", widget.shadowColor));
  }
}

/// Shows an update dialog.
Future showUpdateDialog<T>(
  BuildContext context, {
  required DesktopUpdaterController controller,
  Color? backgroundColor,
  Color? iconColor,
  Color? shadowColor,
}) {
  return showDialog(
    context: context,
    // barrierDismissible: controller.isMandatory == false,
    builder: (context) {
      return UpdateDialogWidget(
        controller: controller,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
        shadowColor: shadowColor,
      );
    },
  );
}

/// A widget that shows an update dialog.
class UpdateDialogWidget extends StatelessWidget {
  /// Creates an update dialog widget.
  const UpdateDialogWidget({
    super.key,
    required DesktopUpdaterController controller,
    this.backgroundColor,
    this.iconColor,
    this.shadowColor,
  }) : notifier = controller;

  /// The controller for the update dialog.
  final DesktopUpdaterController notifier;

  /// The background color of the dialog. if null, it will use Theme.of(context).colorScheme.surfaceContainerHigh,
  final Color? backgroundColor;

  /// The color of the icon. if null, it will use Theme.of(context).colorScheme.primary,
  final Color? iconColor;

  /// The color of the shadow. if null, it will use Theme.of(context).shadowColor,
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return ListenableBuilder(
          listenable: notifier,
          builder: (context, child) {
            return AlertDialog(
              backgroundColor: backgroundColor,
              iconColor: iconColor,
              shadowColor: shadowColor,
              title: Text(
                notifier.getLocalization?.updateAvailableText ??
                    "Update Available",
              ),
              content: Text(
                "${getLocalizedString(
                      notifier.getLocalization?.newVersionAvailableText,
                      [
                        notifier.appName,
                        notifier.appVersion,
                      ],
                    ) ?? (getLocalizedString(
                      "{} {} is available",
                      [
                        notifier.appName,
                        notifier.appVersion,
                      ],
                    )) ?? ""}, ${getLocalizedString(
                      notifier.getLocalization?.newVersionLongText,
                      [
                        notifier.appName,
                        notifier.appVersion,
                      ],
                    ) ?? (getLocalizedString(
                      "New version is ready to download, click the button below to start downloading. This will download {} MB of data.",
                      [
                        ((notifier.downloadSize ?? 0) / 1024)
                            .toStringAsFixed(2),
                      ],
                    )) ?? ""}",
              ),
              actions: [
                if ((notifier.isDownloading) && !(notifier.isDownloaded))
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            value: notifier.downloadProgress,
                          ),
                        ),
                        label: Row(
                          children: [
                            Text(
                              "${((notifier.downloadProgress) * 100).toInt()}% (${((notifier.downloadedSize) / 1024).toStringAsFixed(2)} MB / ${((notifier.downloadSize ?? 0.0) / 1024).toStringAsFixed(2)} MB)",
                            ),
                          ],
                        ),
                        onPressed: null,
                      ),
                    ],
                  )
                else if (notifier.isDownloading == false &&
                    (notifier.isDownloaded))
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.restart_alt),
                        label: Text(
                          notifier.getLocalization?.restartText ??
                              "Restart to update",
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                  notifier.getLocalization?.warningTitleText ??
                                      "Are you sure?",
                                ),
                                content: Text(
                                  notifier.getLocalization
                                          ?.restartWarningText ??
                                      "A restart is required to complete the update installation.\nAny unsaved changes will be lost. Would you like to restart now?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      notifier.getLocalization
                                              ?.warningCancelText ??
                                          "Not now",
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: notifier.restartApp,
                                    child: Text(
                                      notifier.getLocalization
                                              ?.warningConfirmText ??
                                          "Restart",
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if ((notifier.isMandatory) == false)
                        TextButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text("Skip this version"),
                          onPressed: notifier.makeSkipUpdate,
                        ),
                      if ((notifier.isMandatory) == false)
                        const SizedBox(
                          width: 8,
                        ),
                      TextButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text("Download"),
                        onPressed: notifier.downloadUpdate,
                      ),
                    ],
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<DesktopUpdaterController>("notifier", notifier),
      )
      ..add(ColorProperty("backgroundColor", backgroundColor))
      ..add(ColorProperty("iconColor", iconColor))
      ..add(ColorProperty("shadowColor", shadowColor));
  }
}
