# MacOS LanguageMatching工具类应用开发(国际化)

说明：一款工具类MacOS应用,是自动把Excel中的多国语言拷贝到工程文件中，提高工作效率。

开发过程简单梳理，分为三步
## 1、解析选定的工程路径，填充字典resourceUrlMark（key是lproj文件实际路径，value是Excel表格中多语言标识key）

## 2、解析Excel数据 转化成 字典

## 3、开始比对key，获取Excel数据，获取key对应的value填充，写入工程文件

```
附录：属性说明
@property (nonatomic, strong) NSMutableDictionary *resourceDate;//@{ path: @{subPath: @{key:value}}}
@property (nonatomic, strong) NSMutableDictionary *resourceUrlMark;//@{ subPath:@"多语言标识de"}
@property (nonatomic, strong) NSDictionary *excelData;// 解析Excel后得到的字典
@property (nonatomic, strong) NSDictionary *InfoDic;//  多语言文件名 ：国家语言
```
