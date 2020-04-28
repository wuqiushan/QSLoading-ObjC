[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![language](https://img.shields.io/badge/language-objective--c-green.svg)](1) 

### 概述
本框架为iOS版的加载库，使用类方法，使用非常方便。
<img src="https://github.com/wuqiushan/QSLoading-ObjC/blob/master/QSLoading.gif" width="400" height="790">

### 使用方法
```Objective-C
    [QSLoading showTitle:@"加载中..."   duration:10.0 didDismiss:^{
        NSLog(@"消失回调");
    }];
```

### 许可证
所有源代码均根据MIT许可证进行许可。