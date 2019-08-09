# JYLazyLoader



效果：

![lazyload](https://s2.ax1x.com/2019/08/07/eILMOU.gif)



源起：[Xcode 懒加载生成插件](https://blog.devorz.com/2019/08/07/Xcode-Extension-Lazy-Load/)



## 使用说明

* 在 [Release](https://github.com/iDevOrz/JYLazyLoader/releases) 页下载最新版本， 将解压得到的 JYLazyLoader.app 拖入 应用程序文件夹。

* 双击启动该应用。

* 打开系统偏好设置->拓展->Xcode Source Editor 。勾选LazyLoad

* 重启 Xcode，你就可以在Xcode 菜单栏的Editor 中找到该插件。

* 其中包含withMark 和withoutMark 两个选项，区别在于会不会生成``//MARK: Lazy Load`` 的标识
* tips: 可以在Xcode 的 Preferences->Key Bindings 中搜索 LazyLoad 为其设置一个顺手的快捷键，例如移除不常用的 Duplicate 的快捷键 ⌘+D,将其设置给  LazyLoad →withMark。然后给 Delete Line 也设置一个快捷键。这样你可以很方便的使用插件生成懒加载代码以及删除那些不必要的属性设置。

