// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.
import 'dart:ui';
import 'package:faceunity_ui/Models/BaseModel.dart';
import 'package:faceunity_ui/ResetDialog.dart';
import 'package:faceunity_ui/Tools/DialogManager.dart';
import 'package:faceunity_ui/Tools/FUDataDefine.dart';
import 'package:faceunity_ui/Tools/FUImageTool.dart';
import 'package:faceunity_ui/Tools/ViewModelManager.dart';
import 'package:faceunity_ui/ViewModels/BaseViewModel.dart';
import 'package:faceunity_ui/CompareBtn.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FaceunityUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomePage();
    //  MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     // This is the theme of your application.
    //     //
    //     // Try running your application with "flutter run". You'll see the
    //     // application has a blue toolbar. Then, without quitting the app, try
    //     // changing the primarySwatch below to Colors.green and then invoke
    //     // "hot reload" (press "r" in the console where you ran "flutter run",
    //     // or simply save your changes to "hot reload" in a Flutter IDE).
    //     // Notice that the counter didn't reset back to zero; the application
    //     // is not restarted.
    //     primarySwatch: Colors.blue,
    //     switchTheme: SwitchThemeData(
    //         thumbColor: MaterialStateProperty.all(Colors.white),
    //         trackColor: MaterialStateProperty.all(Colors.green[600]),
    //         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
    //   ),
    //   home: HomePage(),
    // );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ViewModelManager _viewModelManager;
  late final DialogManager _dialogManager;
  late final _screenWidth;
  @override
  void initState() {
    super.initState();
    _viewModelManager = ViewModelManager();
    _dialogManager = DialogManager();
    _screenWidth = window.physicalSize.width / window.devicePixelRatio;
  }

  @override
  Widget build(BuildContext context) {
    return _mainUI();
    // Scaffold(
    //   appBar: AppBar(
    //     // Here we take the value from the MyHomePage object that was created by
    //     // the App.build method, and use it to set our appbar title.
    //     title: Text("Faceunity"),
    //   ),
    //   body: Center(
    //       // Center is a layout widget. It takes a single child and positions it
    //       // in the middle of the parent.
    //       child: _mainUI()),
    // );
  }

  Widget _mainUI() {
    //底部总的菜单栏业务模型监听
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => _viewModelManager,
        ),
        ChangeNotifierProvider(create: (context) => _dialogManager),
      ],
      child: Stack(
        children: [
          Opacity(
            opacity: 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                //美肤、美型、美体、美妆等子业务
                _mainBiz(),
                //分割线
                Container(
                  height: 1.0,
                ),
                //底部标题widget

                _titleListView(),
              ],
            ),
          ),
          ResetDialog(() {
            _viewModelManager.reset();
            _dialogManager.isShowDialog = false;
          }, () => _dialogManager.isShowDialog = false),
        ],
      ),
    );
  }

  //美肤、美型、美体、美妆等子业务
  Widget _mainBiz() {
    return Selector<ViewModelManager, BaseViewModel>(
        builder: (context, viewModel, child) {
          ViewModelManager manager = _viewModelManager;
          Widget compareBtn = Visibility(
              visible: manager.curViewModel.dataModel.showSwitch,
              child: CompareBtn(manager.curViewModel.dataModel.isOn));
          Widget collectionView = Container();

          if (manager.curViewModel.dataModel.bizType ==
                  FUDataType.FUDataTypeBeautySkin ||
              manager.curViewModel.dataModel.bizType ==
                  FUDataType.FUDataTypeBeautyShape ||
              manager.curViewModel.dataModel.bizType ==
                  FUDataType.FUDataTypebody) {
            collectionView = _styleFirstListView();
          } else if (manager.curViewModel.dataModel.bizType ==
              FUDataType.FUDataTypeBeautyFilter) {
            collectionView = _styleSecondListView();
          } else {
            //后续其他模块不同UI样式可以在此添加
          }
          return Visibility(
            visible: manager.showSubUI,
            child: Column(
              children: [
                Container(
                  height: 40,
                  child: compareBtn,
                ),
                _sliderView(),
                collectionView,
              ],
            ),
          );
        },
        shouldRebuild: (preViewModel, nextViewModel) {
          return true;
        },
        selector: (context, manager) => manager.curViewModel);
  }

  Widget _sliderView() {
    return Consumer<ViewModelManager>(builder: (context, manager, child) {
      BaseViewModel viewModel = manager.curViewModel;
      double value = 0.0;
      int percent;
      String valueStr; //百分比字符串
      //是否以中间为起始点
      bool middle = false;
      //滑块滑过的轨迹颜色
      Color activeTrackColor;
      //滑块未滑过的轨迹颜色
      Color inactiveTrackColor = Colors.white;
      if (viewModel.selectedModel != null) {
        value = viewModel.selectedModel!.value / viewModel.selectedModel!.ratio;
        middle = viewModel.selectedModel!.midSlider;
      }

      // //自定义中间滑块划过的痕迹长度
      // double midleContainerWidth = 0.0;

      if (middle) {
        activeTrackColor = Colors.white;
        percent = ((value - 0.5) * 100).toInt();
        valueStr = "$percent";
        if ((value - 0.5) > 0) {
          // midleContainerWidth = (value - 0.5) * 100;
        } else {
          // midleContainerWidth = (0.5 - value) * 100;
        }
      } else {
        percent = (value * 100).toInt();
        valueStr = "$percent";
        activeTrackColor = Color(0xFF5EC7FE);
      }

      return Container(
        padding: EdgeInsets.fromLTRB(15, 0, 0, 15),
        height: 50,
        width: _screenWidth,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Visibility(
              visible: viewModel.showSlider(),
              child: Positioned(
                  child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 2,
                  activeTrackColor: activeTrackColor,
                  inactiveTrackColor: inactiveTrackColor,
                  thumbShape: RoundSliderThumbShape(
                      //  滑块形状，可以自定义
                      enabledThumbRadius: 8 // 滑块大小
                      ),
                ),
                child: Slider(
                    label: valueStr,
                    divisions: 100,
                    value: value,
                    onChanged: (double newValue) =>
                        manager.sliderValueChange(newValue)),
              )),
            ),
            Container(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 15),
                width: middle ? 2 : 0,
                height: 10,
                color: Color(0xFF5EC7FE)),
          ],
        ),
      );
    });
    //slider更新受到 curViewModel 和 curViewModel.selectedIndex 以及value值本身影响
    // return Selector<ViewModelManager, Tuple2<int, BaseViewModel>>(
    //     selector: (context, manager) =>
    //         Tuple2(manager.curViewModel.selectedIndex, manager.curViewModel),
    //     builder: (context, viewModel, child) {
    //       BaseViewModel viewModel = _viewModelManager.curViewModel;
    //       double value = 0.0;
    //       if (viewModel.selectedModel != null) {
    //         value =
    //             viewModel.selectedModel!.value / viewModel.selectedModel!.ratio;
    //       }

    //       int percent = (value * 100).toInt();
    //       String valueStr = "$percent";
    //       return Container(
    //           height: 50,
    //           width: double.infinity,
    //           color: Colors.black,
    //           child: Visibility(
    //             visible: viewModel.showSlider(),
    //             child: SliderTheme(
    //               data: SliderThemeData(
    //                 trackHeight: 5,
    //                 activeTrackColor: Color(0xFF5EC7FE),
    //                 inactiveTrackColor: Colors.white,
    //                 thumbShape: RoundSliderThumbShape(
    //                     //  滑块形状，可以自定义
    //                     enabledThumbRadius: 8 // 滑块大小
    //                     ),
    //               ),
    //               child: Slider(
    //                   label: valueStr,
    //                   divisions: 100,
    //                   value: value,
    //                   onChanged: (double newValue) =>
    //                       _viewModelManager.sliderValueChange(newValue)),
    //             ),
    //           ));
    //     });
  }

  //美肤、美型、美体系列的conllectionView,具体看UI表现，取个名字脑袋疼
  Widget _styleFirstListView() {
    final _screenWidth = window.physicalSize.width / window.devicePixelRatio;
    String resetImagepath =
        FUImageTool.getImagePathWithRelativePathPre("Asserts/beauty/");
    resetImagepath = resetImagepath + "恢复.png";
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: 90.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Consumer<ViewModelManager>(builder: (context, manager, child) {
            return Padding(
                padding: const EdgeInsets.fromLTRB(15, 3, 0, 0),
                child: Opacity(
                  opacity: manager.isDefaultValue() == true ? 0.7 : 1.0,
                  child: GestureDetector(
                    onTap: () {
                      //reset
                      if (!manager.isDefaultValue()) {
                        _dialogManager.isShowDialog = true;
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image(
                          height: 54.0,
                          width: 54.0,
                          image: FUImageTool.getAssertImage(resetImagepath),
                        ),
                        Text("恢复",
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                ));
          }),
          Container(
            width: 21,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 54.0,
                    width: 1,
                    color: Colors.white24,
                  ),
                ),
                Text("占位",
                    style: TextStyle(color: Colors.transparent, fontSize: 10)),
              ],
            ),
          ),
          Container(
            height: 90.0,
            width: _screenWidth - 95,
            child: _commonCell(),
          ),
        ],
      ),
    );
  }

  //复用cell
  Widget _commonCell() {
    return Container(
        color: Colors.black,
        height: 90,
        // width: double.infinity,
        child: Selector<ViewModelManager, int>(
          selector: (context, manager) => manager.curViewModel.selectedIndex,
          shouldRebuild: (preIndex, nextIndex) {
            return preIndex != nextIndex;
          },
          builder: (context, index, child) {
            BaseViewModel viewModel = _viewModelManager.curViewModel;
            List<BaseModel> dataList =
                viewModel.dataModel.dataList as List<BaseModel>;
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
              scrollDirection: Axis.horizontal,
              separatorBuilder: (BuildContext context, int index) {
                return VerticalDivider(
                  width: 10,
                  color: Color(0x00000000),
                );
              },
              itemBuilder: (BuildContext context, int index) {
                String imagePath =
                    FUImageTool.selectedImageState(index, viewModel);
                String title = dataList[index].title;
                FUDataType bizType = viewModel.dataModel.bizType;
                //是否选中时显示边框
                bool hasBoard = false;
                bool selected = false;
                if (viewModel.selectedIndex == index) {
                  selected = true;
                }
                if (selected == true &&
                    bizType == FUDataType.FUDataTypeBeautyFilter) {
                  hasBoard = true;
                }
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => _viewModelManager.selectedItem(index),
                        child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: hasBoard == true
                                        ? Color(0xFF5EC7FE)
                                        : Colors.transparent,
                                    width: 3.0),
                                borderRadius: BorderRadius.circular(5.0)),
                            child: Image(
                              height: 54.0,
                              width: 54.0,
                              image: FUImageTool.getAssertImage(imagePath),
                            )),
                      ),
                      Text(title,
                          style: TextStyle(color: Colors.white, fontSize: 10)),
                    ],
                  ),
                );
              },
              itemCount: dataList.length,
            );
          },
        ));
  }

  //滤镜
  Widget _styleSecondListView() {
    return Container(
      width: double.infinity,
      height: 90.0,
      child: _commonCell(),
    );
  }

  //标题列表
  Widget _titleListView() {
    return Consumer<ViewModelManager>(builder: (context, manager, child) {
      List<BaseViewModel> dataList = manager.viewModelList;
      return Container(
        height: 54,
        width: _screenWidth,
        color: Colors.black,
        child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
            scrollDirection: Axis.horizontal,
            itemCount: dataList.length,
            separatorBuilder: (BuildContext context, int index) {
              return VerticalDivider(
                width: 10,
                color: Color(0x00000000),
              );
            },
            itemBuilder: (BuildContext context, int index) {
              String title = dataList[index].dataModel.title;
              bool selected = manager.seletedViewModelIndex == index;
              return Container(
                  width: 75,
                  child: TextButton(
                    onPressed: () {
                      manager.clickTitleItem(index);
                    },
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(title,
                              style: TextStyle(
                                  color: selected == true
                                      ? Color(0xff5ec7fe)
                                      : Colors.white,
                                  fontSize: 13)),
                        ),
                      ],
                    ),
                  ));
            }),
      );
    });
  }
}
