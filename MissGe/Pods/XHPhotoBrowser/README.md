# XHPhotoBrowser
photo browser

-----
- 用 Objective-C 实现的photo browser的效果, 基于YYKit的Demo中的一个photoView改造而来, 仅供学习交流使用. 
- 项目依赖[YYWebImage](https://github.com/ibireme/YYWebImage)
- 支持 ARC 和 CocoaPods 
- iOS 8.0 (理论上iOS7.0也没问题, 但是我没有设备测试,所以...)
- 编译环境 Xcode 9.0, Swift 4.0

-----

### CocoaPods:

`pod 'XHPhotoBrowser'`


### 有什么问题请issue我

GitHub：[chengxianghe](https://github.com/chengxianghe) 

## Version 1.1.1:
- 适配iOS11
- 适配iPhone X界面
- 使用Xcode 9.0, Swift 4.0重新编译
- Demo升级Swift 4.0


## Version 1.0.8:
- 修复BrowserController打开时候有动画卡顿的问题
- 增加判断当前是否正在展示相册的接口 ***isPresented***
- 增加BrowserController自定义属性 ***showBrowserWhenDidload***
- 修改item命名
- 新增单击图片的处理接口 ***singleTapOption***
- 升级Xcode8 适配Swift 3.0
- 开放 ***pageControl*** 的定制接口
- 增加和修改注释

...

## Version 1.0.2:
- 删除多余的log
- 修复部分bug

## Version 1.0.1:
- 基本完成功能
- 支持cell中的布局显示,以view的形式,请参照demo;
- 支持collectionView的布局展示,请参照demo;
- 支持push一个controller的形式展示,请参照demo;
- 其余的功能请参照预览图;

## Screenshots

#### 开启blur预览图
<img src="https://github.com/chengxianghe/watch-gif/blob/master/photobrower1.png?raw=true" width = "200" alt="开启blur预览图" align=center />

#### 以controller形式的展示
<img src="https://github.com/chengxianghe/watch-gif/blob/master/photobrower2.png?raw=true" width = "200" alt="以controller形式的展示" align=center />

#### 关闭blur 显示caption
<img src="https://github.com/chengxianghe/watch-gif/blob/master/photobrower3.png?raw=true" width = "200" alt="关闭blur 显示caption" align=center />

- GIF

#### 总体预览图
![image](https://github.com/chengxianghe/watch-gif/blob/master/photobrower1.gif?raw=true)

#### blur预览图
![image](https://github.com/chengxianghe/watch-gif/blob/master/photobrower2.gif?raw=true)

#### Opensource libraries used

- [YYWebImage](https://github.com/ibireme/YYWebImage)


### License
----

This code is distributed under the terms and conditions of the MIT license.
