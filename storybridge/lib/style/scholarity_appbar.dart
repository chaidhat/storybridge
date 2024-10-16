import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/focus_service.dart';
import 'package:mooc/style/scholarity_colors.dart' as scholarity_color;
import 'package:mooc/services/translation_service.dart' as translation_service;

class ScholarityAppbar extends StatelessWidget {
  // constructor
  const ScholarityAppbar({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: scholarity_color.background,
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
                    ScholarityAccountIndicator(
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

class ScholarityTabHeader {
  final String tabName;
  final IconData tabIcon;

  Function? onUpdate;
  bool isVisible;
  ScholarityTabHeader(
      {required this.tabName,
      required this.tabIcon,
      this.isVisible = true,
      this.onUpdate});
}

class ScholarityScaffold extends StatefulWidget {
  final bool hasAppbar;
  final List<ScholarityTabHeader> tabNames;
  final List<Widget> body;
  final List<Widget> tabs;
  final Widget? tabPrefix, tabSuffix;
  final bool forceDesktop;
  final bool isTabRightAligned;
  final int startingTab;

  ScholarityScaffold({
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
  State<ScholarityScaffold> createState() => _ScholarityScaffoldState();
}

class _ScholarityScaffoldState extends State<ScholarityScaffold>
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
      backgroundColor: scholarity_color.backgroundDim,
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const translation_service.LanguageFab(),
            const SizedBox(width: 10),
            FloatingActionButton(
              backgroundColor: scholarity_color.background,
              tooltip: "Dark Mode",
              onPressed: () async {
                scholarity_color.toggleDarkMode();
                Navigator.pushNamed(context, '/reload');
              },
              child:
                  Icon(Icons.contrast_rounded, color: scholarity_color.black),
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          ScholarityFocusDismisser(
            child: Column(children: [
              widget.hasAppbar ? const ScholarityAppbar() : Container(),
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
                    child: ScholarityHolder(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.body,
                          ),
                          _numberOfTabs > 1 && !isMobileScreen(context)
                              ? ScholarityTabBar(
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
                      child: ScholarityTabBar(
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
              : const _ScholarityDesktopWarning()
        ],
      ),
    );
  }
}

class ScholarityTabBar extends StatefulWidget {
  // members of MyWidget
  final List<ScholarityTabHeader> tabNames;
  final bool isRightAligned;
  final TabController controller;

  // constructor
  const ScholarityTabBar({
    Key? key,
    required this.tabNames,
    required this.controller,
    this.isRightAligned = false,
  }) : super(key: key);

  @override
  State<ScholarityTabBar> createState() => _ScholarityTabBarState();
}

class _ScholarityTabBarState extends State<ScholarityTabBar> {
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
            child: ScholarityTextBasic(widget.tabNames[i].tabName,
                style: TextStyle(
                  fontSize: scholarityTextH5Style.fontSize,
                  fontWeight: FontWeight.w500,
                  color: scholarity_color.darkGrey,
                )),
          ),
        );
      }),
    );
  }
}

class ScholarityTabPageController {
  bool mobileShowSidebar = false;
  late Function() update;
  ScholarityTabPageController();
}

class ScholarityTabPage extends StatefulWidget {
  final List<Widget> body;
  final List<Widget>? sideBar, rightSideBar;
  final bool hasSideBarPadding, hasRightSideBarPadding;
  final bool hasReducedPadding;
  final bool hasVeryReducedPadding;
  final bool disableScroll;
  final ScholarityTabPageController? tabPageController;
  final ScrollController? scrollController;
  // constructor

  // ignore: prefer_const_constructors_in_immutables
  ScholarityTabPage({
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
  State<ScholarityTabPage> createState() => _ScholarityTabPageState();
}

class _ScholarityTabPageState extends State<ScholarityTabPage> {
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
        color: scholarity_color.background,
        //boxShadow: [scholarity_color.shadow],
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
                        ? scholarity_color.scholaritySideBarWidth
                        : 0,
                    right: (widget.hasVeryReducedPadding &&
                                widget.rightSideBar != null) ||
                            (!widget.hasVeryReducedPadding &&
                                    widget.sideBar != null) &&
                                !isMobileScreen(context)
                        ? scholarity_color.scholaritySideBarWidth
                        : 0),
                child: ScholarityHolder(
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
                            width: scholarity_color.scholaritySideBarWidth,
                            constraints: BoxConstraints(
                                minHeight: MediaQuery.of(context).size.height),
                            child: SingleChildScrollView(
                              child: ScholarityHolder(
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
                            color: scholarity_color.borderColor)
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
                              color: scholarity_color.borderColor),
                          Container(
                              width: scholarity_color.scholaritySideBarWidth,
                              constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.of(context).size.height),
                              child: SingleChildScrollView(
                                child: ScholarityHolder(
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
                  decoration: BoxDecoration(color: scholarity_color.background),
                  child: ScholarityHolder(
                      hasPadding: widget.hasSideBarPadding,
                      child: Column(children: widget.sideBar!))),
          widget.sideBar == null || !isMobileScreen(context)
              ? Container()
              : ScholarityPadding(
                  child: ScholarityIconButton(
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

class ScholarityLoading extends StatelessWidget {
  final bool white;
  // constructor
  const ScholarityLoading({Key? key, this.white = false}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
                color:
                    white ? Colors.white : scholarity_color.scholarityAccent)));
  }
}

class ScholaritySideBarButton extends StatelessWidget {
  // members of MyWidget
  final String label;
  final IconData icon;
  final bool selected;
  final Function onPressed;
  final bool isSpecial;
  final bool isDisabled;

  // constructor
  const ScholaritySideBarButton({
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
                    scholarity_color.scholarityAccentBackground)
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
                        ? scholarity_color.scholarityAccent
                        : scholarity_color.grey)
                    : scholarity_color.lightGrey,
                size: 22),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: ScholarityTextH5(label,
                          red: selected, bold: isSpecial, dim: isDisabled),
                    ),
                    const SizedBox(width: 10),
                    !isDisabled
                        ? Container()
                        : Icon(Icons.lock_rounded,
                            color: scholarity_color.lightGrey, size: 22),
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
class ScholarityPageLoading extends StatefulWidget {
  final bool useAltStyle;
  const ScholarityPageLoading({Key? key, this.useAltStyle = false})
      : super(key: key);

  @override
  _ScholarityPageLoadingState createState() => _ScholarityPageLoadingState();
}

// myPage state
class _ScholarityPageLoadingState extends State<ScholarityPageLoading>
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
                scholarity_color.backgroundDim,
                !widget.useAltStyle
                    ? scholarity_color.backgroundLoading
                    : scholarity_color.scholarityAccentLight,
                scholarity_color.backgroundDim,
                !widget.useAltStyle
                    ? scholarity_color.backgroundLoading
                    : scholarity_color.scholarityAccentLight,
                scholarity_color.backgroundDim,
              ]).createShader(rect);
            },
          ),
        ],
      ),
    );
  }
}

// myPage class which creates a state on call
class ScholarityBoxLoading extends StatefulWidget {
  final double height, width;
  const ScholarityBoxLoading(
      {Key? key, required this.height, required this.width})
      : super(key: key);

  @override
  _ScholarityBoxLoadingState createState() => _ScholarityBoxLoadingState();
}

// myPage state
class _ScholarityBoxLoadingState extends State<ScholarityBoxLoading>
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
                scholarity_color.backgroundDim,
                scholarity_color.backgroundLoading,
                scholarity_color.backgroundDim,
                scholarity_color.backgroundLoading,
                scholarity_color.backgroundDim,
              ]).createShader(rect);
            },
          ),
        ],
      ),
    );
  }
}

class _ScholarityDesktopWarning extends StatelessWidget {
  // constructor
  const _ScholarityDesktopWarning({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xD0FFFFFF),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScholarityTextBasic("Please use a desktop",
                style: scholarityTextH2Style, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ScholarityTextBasic(
                "Scholarity Teaching console does not work with a mobile phone.",
                style: scholarityTextH2BStyle,
                textAlign: TextAlign.center),
          ],
        )));
  }
}
