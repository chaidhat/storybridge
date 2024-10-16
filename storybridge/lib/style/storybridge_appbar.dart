import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/services/focus_service.dart';
import 'package:mooc/style/storybridge_colors.dart' as storybridge_color;
import 'package:mooc/services/translation_service.dart' as translation_service;

class StorybridgeAppbar extends StatelessWidget {
  // constructor
  const StorybridgeAppbar({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: storybridge_color.background,
      ),
      child: const Stack(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                        height: 25,
                        child: Image(
                            fit: BoxFit.fill,
                            image: AssetImage('assets/logo-1.png'))),
                    SizedBox(width: 20),
                  ],
                ),
              )),
          Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StorybridgeAccountIndicator(
                      organizationId: null,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
    /*
          */
  }
}

class StorybridgeTabHeader {
  final String tabName;
  final IconData tabIcon;

  Function? onUpdate;
  bool isVisible;
  StorybridgeTabHeader(
      {required this.tabName,
      required this.tabIcon,
      this.isVisible = true,
      this.onUpdate});
}

class StorybridgeScaffold extends StatefulWidget {
  final bool hasAppbar;
  final List<StorybridgeTabHeader> tabNames;
  final List<Widget> body;
  final List<Widget> tabs;
  final Widget? tabPrefix, tabSuffix;
  final bool forceDesktop;
  final bool isTabRightAligned;
  final int startingTab;

  StorybridgeScaffold({
    Key? key,
    required this.hasAppbar,
    required this.body,
    required this.tabNames,
    required this.tabs,
    this.tabPrefix,
    this.tabSuffix,
    this.forceDesktop = false,
    this.startingTab = 0,
    this.isTabRightAligned = false,
  }) : super(key: key);

  @override
  State<StorybridgeScaffold> createState() => _StorybridgeScaffoldState();
}

class _StorybridgeScaffoldState extends State<StorybridgeScaffold>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _numberOfTabs;

  @override
  void initState() {
    super.initState();
    _numberOfTabs = widget.tabs.length;
    _tabController = TabController(vsync: this, length: _numberOfTabs);
    _tabController.index = widget.startingTab;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // this is to make sure it fills the entire column
    //body.add(Container());
    return Scaffold(
      backgroundColor: storybridge_color.backgroundDim,
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const translation_service.LanguageFab(),
            const SizedBox(width: 10),
            FloatingActionButton(
              backgroundColor: storybridge_color.background,
              tooltip: "Dark Mode",
              onPressed: () async {
                storybridge_color.toggleDarkMode();
                Navigator.pushNamed(context, '/reload');
              },
              child:
                  Icon(Icons.contrast_rounded, color: storybridge_color.black),
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          StorybridgeFocusDismisser(
            child: Column(children: [
              widget.hasAppbar ? const StorybridgeAppbar() : Container(),
              // padding to move
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                        child: widget.tabPrefix ?? Container(),
                      )),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: widget.tabSuffix ?? Container())),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: StorybridgeHolder(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.body,
                          ),
                          _numberOfTabs > 1 && !isMobileScreen(context)
                              ? StorybridgeTabBar(
                                  isRightAligned: widget.isTabRightAligned,
                                  tabNames: widget.tabNames,
                                  controller: _tabController,
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              !isMobileScreen(context)
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StorybridgeTabBar(
                          tabNames: widget.tabNames,
                          controller: _tabController),
                    ),
              Expanded(
                  child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: widget.tabs,
              )),
            ]),
          ),
          !(isMobileScreen(context) && widget.forceDesktop)
              ? Container()
              : const _StorybridgeDesktopWarning()
        ],
      ),
    );
  }
}

class StorybridgeTabBar extends StatefulWidget {
  // members of MyWidget
  final List<StorybridgeTabHeader> tabNames;
  final bool isRightAligned;
  final TabController controller;

  // constructor
  const StorybridgeTabBar({
    Key? key,
    required this.tabNames,
    required this.controller,
    this.isRightAligned = false,
  }) : super(key: key);

  @override
  State<StorybridgeTabBar> createState() => _StorybridgeTabBarState();
}

class _StorybridgeTabBarState extends State<StorybridgeTabBar> {
  // main build function

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(widget.tabNames.length + 1, (int j) {
        if (j == 0) {
          if (!widget.isRightAligned) {
            return Container();
          } else {
            return Expanded(child: Container());
          }
        }
        int i = j - 1;
        if (widget.tabNames[i].onUpdate == null) {
          widget.tabNames[i].onUpdate = update;
        }
        if (!widget.tabNames[i].isVisible) {
          return Container();
        }
        return InkWell(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () {
            widget.controller.index = i;
            setState(() {});
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: widget.controller.index == i
                    ? const Color(0x18808080)
                    : Colors.transparent),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: StorybridgeTextBasic(widget.tabNames[i].tabName,
                style: TextStyle(
                  fontSize: storybridgeTextH5Style.fontSize,
                  fontWeight: FontWeight.w500,
                  color: storybridge_color.darkGrey,
                )),
          ),
        );
      }),
    );
  }
}

class StorybridgeTabPageController {
  bool mobileShowSidebar = false;
  late Function() update;
  StorybridgeTabPageController();
}

class StorybridgeTabPage extends StatefulWidget {
  final List<Widget> body;
  final List<Widget>? sideBar, rightSideBar;
  final bool hasSideBarPadding, hasRightSideBarPadding;
  final bool hasReducedPadding;
  final bool hasVeryReducedPadding;
  final bool disableScroll;
  final StorybridgeTabPageController? tabPageController;
  final ScrollController? scrollController;
  // constructor

  // ignore: prefer_const_constructors_in_immutables
  StorybridgeTabPage({
    Key? key,
    required this.body,
    this.sideBar,
    this.rightSideBar,
    this.hasSideBarPadding = true,
    this.hasRightSideBarPadding = true,
    this.hasReducedPadding = false,
    this.hasVeryReducedPadding = false,
    this.scrollController,
    this.disableScroll = false,
    this.tabPageController,
  }) : super(key: key);

  @override
  State<StorybridgeTabPage> createState() => _StorybridgeTabPageState();
}

class _StorybridgeTabPageState extends State<StorybridgeTabPage> {
  @override
  void initState() {
    widget.tabPageController?.update = () {
      setState(() {});
    };
    super.initState();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    bool mobileShowSidebar = (widget.tabPageController != null
        ? !widget.tabPageController!.mobileShowSidebar
        : false);
    widget.body.add(Container());
    return Container(
      decoration: BoxDecoration(
        color: storybridge_color.background,
        //boxShadow: [storybridge_color.shadow],
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: !widget.disableScroll
                ? null
                : const NeverScrollableScrollPhysics(),
            controller: widget.scrollController,
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(
                    left: widget.sideBar != null && !isMobileScreen(context)
                        ? storybridge_color.storybridgeSideBarWidth
                        : 0,
                    right: (widget.hasVeryReducedPadding &&
                                widget.rightSideBar != null) ||
                            (!widget.hasVeryReducedPadding &&
                                    widget.sideBar != null) &&
                                !isMobileScreen(context)
                        ? storybridge_color.storybridgeSideBarWidth
                        : 0),
                child: StorybridgeHolder(
                  hasReducedPadding: widget.hasReducedPadding,
                  hasVeryReducedPadding: widget.hasVeryReducedPadding,
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.body,
                      ),
                      const SizedBox(height: 300),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.sideBar != null && !isMobileScreen(context)
                  ? Row(
                      children: [
                        Container(
                            width: storybridge_color.storybridgeSideBarWidth,
                            constraints: BoxConstraints(
                                minHeight: MediaQuery.of(context).size.height),
                            child: SingleChildScrollView(
                              child: StorybridgeHolder(
                                  hasPadding: widget.hasSideBarPadding,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: widget.sideBar!,
                                  )),
                            )),
                        VerticalDivider(
                            indent: 20,
                            width: 20,
                            thickness: 1,
                            endIndent: 20,
                            color: storybridge_color.borderColor)
                      ],
                    )
                  : Container(),
              Expanded(child: Container()),
              widget.rightSideBar != null && !isMobileScreen(context)
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          VerticalDivider(
                              indent: 20,
                              width: 20,
                              thickness: 1,
                              endIndent: 20,
                              color: storybridge_color.borderColor),
                          Container(
                              width: storybridge_color.storybridgeSideBarWidth,
                              constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.of(context).size.height),
                              child: SingleChildScrollView(
                                child: StorybridgeHolder(
                                    hasPadding: widget.hasRightSideBarPadding,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: widget.rightSideBar!,
                                    )),
                              )),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
          mobileShowSidebar ||
                  !isMobileScreen(context) ||
                  widget.sideBar == null
              ? Container()
              : Container(
                  decoration:
                      BoxDecoration(color: storybridge_color.background),
                  child: StorybridgeHolder(
                      hasPadding: widget.hasSideBarPadding,
                      child: Column(children: widget.sideBar!))),
          widget.sideBar == null || !isMobileScreen(context)
              ? Container()
              : StorybridgePadding(
                  child: StorybridgeIconButton(
                    icon: Icons.list_rounded,
                    onPressed: () {
                      setState(() {
                        if (widget.tabPageController != null) {
                          widget.tabPageController!.mobileShowSidebar =
                              !widget.tabPageController!.mobileShowSidebar;
                        }
                      });
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class StorybridgeLoading extends StatelessWidget {
  final bool white;
  // constructor
  const StorybridgeLoading({Key? key, this.white = false}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
                color: white
                    ? Colors.white
                    : storybridge_color.storybridgeAccent)));
  }
}

class StorybridgeSideBarButton extends StatelessWidget {
  // members of MyWidget
  final String label;
  final IconData icon;
  final bool selected;
  final Function onPressed;
  final bool isSpecial;
  final bool isDisabled;

  // constructor
  const StorybridgeSideBarButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isSpecial = false,
    this.selected = false,
    this.isDisabled = false,
  }) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: !isDisabled
            ? () {
                onPressed();
              }
            : null,
        style: ButtonStyle(
            backgroundColor: selected
                ? MaterialStateProperty.all<Color>(
                    storybridge_color.storybridgeAccentBackground)
                : null,
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon,
                color: !isDisabled
                    ? (selected
                        ? storybridge_color.storybridgeAccent
                        : storybridge_color.grey)
                    : storybridge_color.lightGrey,
                size: 22),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: StorybridgeTextH5(label,
                          red: selected, bold: isSpecial, dim: isDisabled),
                    ),
                    const SizedBox(width: 10),
                    !isDisabled
                        ? Container()
                        : Icon(Icons.lock_rounded,
                            color: storybridge_color.lightGrey, size: 22),
                  ],
                ),
              ),
            ),
            Container(),
          ],
        ));
  }
}

// myPage class which creates a state on call
class StorybridgePageLoading extends StatefulWidget {
  final bool useAltStyle;
  const StorybridgePageLoading({Key? key, this.useAltStyle = false})
      : super(key: key);

  @override
  _StorybridgePageLoadingState createState() => _StorybridgePageLoadingState();
}

// myPage state
class _StorybridgePageLoadingState extends State<StorybridgePageLoading>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation? _animation;
  bool animated = false;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(seconds: 100));
    _animationController!.repeat(reverse: false);
    _animation = Tween(begin: 0.0, end: 100).animate(_animationController!)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return AnimatedOpacity(
      opacity: animated ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      child: Row(
        children: [
          ShaderMask(
            child: Builder(builder: (context) {
              animated = true;

              if (!widget.useAltStyle) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 70,
                        width: 300,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        height: 300,
                        width: 400,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        height: 20,
                        width: 500,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        height: 20,
                        width: 500,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        height: 20,
                        width: 500,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        height: 20,
                        width: 400,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: 500,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        height: 20,
                        width: 500,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        height: 20,
                        width: 500,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        height: 20,
                        width: 400,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ],
                  ),
                );
              }
            }),
            shaderCallback: (rect) {
              return LinearGradient(stops: [
                _animation!.value % 1 - 1,
                _animation!.value % 1 - 0.5,
                _animation!.value % 1,
                _animation!.value % 1 + 0.5,
                _animation!.value % 1 + 1,
              ], colors: [
                storybridge_color.backgroundDim,
                !widget.useAltStyle
                    ? storybridge_color.backgroundLoading
                    : storybridge_color.storybridgeAccentLight,
                storybridge_color.backgroundDim,
                !widget.useAltStyle
                    ? storybridge_color.backgroundLoading
                    : storybridge_color.storybridgeAccentLight,
                storybridge_color.backgroundDim,
              ]).createShader(rect);
            },
          ),
        ],
      ),
    );
  }
}

// myPage class which creates a state on call
class StorybridgeBoxLoading extends StatefulWidget {
  final double height, width;
  const StorybridgeBoxLoading(
      {Key? key, required this.height, required this.width})
      : super(key: key);

  @override
  _StorybridgeBoxLoadingState createState() => _StorybridgeBoxLoadingState();
}

// myPage state
class _StorybridgeBoxLoadingState extends State<StorybridgeBoxLoading>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation? _animation;
  bool animated = false;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(seconds: 100));
    _animationController!.repeat(reverse: false);
    _animation = Tween(begin: 0.0, end: 100).animate(_animationController!)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return AnimatedOpacity(
      opacity: animated ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      child: Row(
        children: [
          ShaderMask(
            child: Builder(builder: (context) {
              animated = true;

              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: widget.height,
                      width: widget.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ],
                ),
              );
            }),
            shaderCallback: (rect) {
              return LinearGradient(stops: [
                _animation!.value % 1 - 1,
                _animation!.value % 1 - 0.5,
                _animation!.value % 1,
                _animation!.value % 1 + 0.5,
                _animation!.value % 1 + 1,
              ], colors: [
                storybridge_color.backgroundDim,
                storybridge_color.backgroundLoading,
                storybridge_color.backgroundDim,
                storybridge_color.backgroundLoading,
                storybridge_color.backgroundDim,
              ]).createShader(rect);
            },
          ),
        ],
      ),
    );
  }
}

class _StorybridgeDesktopWarning extends StatelessWidget {
  // constructor
  const _StorybridgeDesktopWarning({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xD0FFFFFF),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StorybridgeTextBasic("Please use a desktop",
                style: storybridgeTextH2Style, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            StorybridgeTextBasic(
                "Storybridge Teaching console does not work with a mobile phone.",
                style: storybridgeTextH2BStyle,
                textAlign: TextAlign.center),
          ],
        )));
  }
}
