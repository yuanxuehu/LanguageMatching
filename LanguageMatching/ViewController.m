//
//  ViewController.m
//  LanguageMatching
//
//  Created by yuanxuehu on 2019/4/11.
//  Copyright © 2019年 yuanxuehu. All rights reserved.
//

#import "ViewController.h"
#import "LAWExcelTool.h"
#import "Masonry.h"

@interface ViewController()<LAWExcelParserDelegate>
{
    
}
@property (nonatomic, strong) NSMutableDictionary *resourceDate;//@{ path: @{subPath: @{key:value}}}
@property (nonatomic, strong) NSMutableDictionary *resourceUrlMark;//@{ subPath:@"多语言标识de"}
@property (nonatomic, strong) NSDictionary *excelData;// 解析Excel后得到的字典
@property (nonatomic, strong) NSDictionary *InfoDic;//  多语言文件名 ：国家语言

@property (nonatomic, strong) NSTextField *field;
@property (nonatomic, strong) NSTextField *excelField;
@property (nonatomic, strong) NSTextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"frame: %@",NSStringFromRect(self.view.frame));
    NSText *textResources = [[NSText alloc]initWithFrame:NSMakeRect(10, 220, 80, 30)];
    textResources.editable = NO;
    textResources.string = @"Resources";
    textResources.alignment = NSTextAlignmentCenter;
    [self.view addSubview:textResources];
    [textResources mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.top.equalTo(self.view).offset(20);
        make.height.equalTo(@(30));
        make.width.equalTo(@(80));
    }];
    
    self.field = [[NSTextField alloc]initWithFrame:NSMakeRect(100, 220, 260, 30)];
    [self.view addSubview:self.field];
    [self.field mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(100);
        make.top.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-120);
        make.height.equalTo(@(30));
    }];
    
    NSText *textExcel = [[NSText alloc]initWithFrame:NSMakeRect(10, 220, 80, 30)];
    textExcel.string = @"Excel";
    textExcel.editable = NO;
    textExcel.alignment = NSTextAlignmentCenter;
    [self.view addSubview:textExcel];
    [textExcel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.top.equalTo(self.view).offset(70);
        make.height.equalTo(@(30));
        make.width.equalTo(@(80));
    }];
    
    self.excelField = [[NSTextField alloc]initWithFrame:NSMakeRect(100, 140, 260, 30)];
    [self.view addSubview:self.excelField];
    [self.excelField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(100);
        make.top.equalTo(self.view).offset(70);
        make.right.equalTo(self.view).offset(-120);
        make.height.equalTo(@(30));
    }];
    
    NSButton *button = [[NSButton alloc]initWithFrame:NSMakeRect(380, 220, 80, 30)];
    [button setTitle:@"选择"];
    [self.view addSubview:button];
    button.tag = 1;
    [button setTarget:self];
    [button setAction:@selector(buttonPressed:)];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.width.equalTo(@(80));
        make.height.equalTo(@(30));
    }];
    
    NSButton *excelbutton = [[NSButton alloc]initWithFrame:NSMakeRect(380, 140, 80, 30)];
    [excelbutton setTitle:@"选择"];
    [self.view addSubview:excelbutton];
    excelbutton.tag = 2;
    [excelbutton setTarget:self];
    [excelbutton setAction:@selector(buttonPressed:)];
    [excelbutton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(70);
        make.right.equalTo(self.view).offset(-20);
        make.width.equalTo(@(80));
        make.height.equalTo(@(30));
    }];
    
    NSButton *okbutton = [[NSButton alloc]initWithFrame:NSMakeRect(200, 80, 80, 30)];
    [okbutton setTitle:@"开始"];
    [self.view addSubview:okbutton];
    okbutton.tag = 3;
    [okbutton setTarget:self];
    [okbutton setAction:@selector(buttonPressed:)];
    [okbutton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(120);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(80));
        make.height.equalTo(@(30));
    }];
    
//    NSButton *cancelbutton = [[NSButton alloc]initWithFrame:NSMakeRect(380, 140, 80, 30)];
//    [cancelbutton setTitle:@"选择"];
//    [self.view addSubview:cancelbutton];
//    cancelbutton.tag = 4;
//    [cancelbutton setTarget:self];
//    [cancelbutton setAction:@selector(buttonPressed:)];
    
    self.textView = [[NSTextView alloc]init];
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
        make.top.equalTo(self.view).offset(170);
    }];
    
}

#pragma mark - Click Events

- (void)buttonPressed:(NSButton *)sender {
    
    if (sender.tag == 3) {//3 开始遍历Excel数据，获取key对应的value填充
        if (self.resourceUrlMark == nil || self.resourceUrlMark.count == 0 ||
            self.excelData == nil || self.excelData.count == 0) {
            return;
        }
       
        self.textView.string = @"";
        NSLog(@"info:%@",self.resourceUrlMark);
        self.resourceDate = [NSMutableDictionary dictionary];
        //读取原工程文件下的字段数据
        [self resourceDataAnalysis];
        NSLog(@"info:%@",self.resourceDate);
        //核心方法：对比写入
        [self compareAnalysis];
        
    } else {
        NSOpenPanel *opanel = [NSOpenPanel openPanel];
        [opanel setCanChooseDirectories:YES]; //可以打开目录
        [opanel setCanChooseFiles:YES];
        [opanel beginWithCompletionHandler:^(NSModalResponse result) {
            NSLog(@"result :%ld",result);
            if (result == NSApplicationPresentationAutoHideDock) {
                
                if (sender.tag == 2) {//2 选择Excel
                    NSURL *url = [[opanel URLs] firstObject];
                    self.excelField.stringValue = [url path];
                    [self excelData:[url path]];
                } else {//1 选择Resources
                    NSURL *url = [[opanel URLs] firstObject];
                    self.field.stringValue = [url path];
                    self.resourceUrlMark = [NSMutableDictionary dictionary];
                    [self resourceUrl:[url path]];
                }
                NSLog(@"result :%@",[opanel URLs]);
            }
        }];
    }
}

#pragma mark - 1、解析选定的工程路径，填充字典resourceUrlMark（key是lproj文件实际路径，value是Excel表格中多语言标识key）

- (void)resourceUrl:(NSString *)path {
    NSFileManager *fileManger = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    
    if (isExist) {
        if (isDir) {
            NSArray *dirArr = [fileManger contentsOfDirectoryAtPath:path error:nil];
            NSLog(@"dirArr:%@",dirArr);
            for (NSString *str in dirArr) {
                NSString *pathSub = [path stringByAppendingFormat:@"/%@",str];
                if ([self.InfoDic.allKeys containsObject:str]) {
                    //比如德语 resourceUrlMark就是 @"/.../de.lproj/Localizable.strings":@"German";
                    [self.resourceUrlMark setValue:[self.InfoDic objectForKey:str] forKey:pathSub];
                } else {
                    [self resourceUrl:pathSub];
                }
 
            }
        }
    }
}

#pragma mark - 3、开始遍历Excel数据，获取key对应的value填充

- (void)resourceDataAnalysis {
    
    for (NSString *path in self.resourceUrlMark.allKeys) {//遍历所有多语言文件夹路径
        
        NSFileManager *fileManger = [NSFileManager defaultManager];
        BOOL isDir = NO;
        BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
        if (isExist) {
            if (isDir) {
               NSArray *dirArr = [fileManger contentsOfDirectoryAtPath:path error:nil];
                for (NSString *str in dirArr) {
                    if ([str hasSuffix:@".strings"]) {// Localizable.strings
                        NSString *pathSub = [path stringByAppendingFormat:@"/%@",str];
                        NSDictionary *dic = [self analysis:pathSub];
                        if ([self.resourceDate.allKeys containsObject:path]) {
                            NSMutableDictionary *dicUrl = [NSMutableDictionary dictionaryWithDictionary:[self.resourceDate objectForKey:path]];
                            [dicUrl setValue:dic forKey:pathSub];
                            [self.resourceDate setValue:dicUrl forKey:path];
                        } else {
                            [self.resourceDate setValue:@{pathSub:dic} forKey:path];
                        }
                    }
                }
            }
        }
    }
}

- (NSDictionary *)analysis:(NSString *)url {
    
    //NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingFromURL:url error:nil];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    FILE *fp = fopen([url UTF8String], "r");
    if (fp) {
        while (!feof(fp)) {
            char buf[2048];
            fgets(buf, 2048, fp);
            
            // 处理文本信息 转化成 数组文件
            NSString *s = [[NSString alloc]initWithUTF8String:(const char *)buf];
            NSString *ss = [s stringByReplacingOccurrencesOfString:@"\r" withString:@""];//去掉制表符\r
            ss = [ss stringByReplacingOccurrencesOfString:@"\n" withString:@""];//去掉换行符\n
            NSArray *totalArray = [ss componentsSeparatedByString:@"="];//示例 "total" = "￥%1$.2f";
            if (totalArray != nil && ![ss isEqualToString:@""] && totalArray.count == 2) {
                //去除头尾空格
                NSString *key = totalArray[0];
                key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *value = totalArray[1];
                value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [dic setValue:value forKey:key];
            } else {
                NSLog(@"aa");
            }
            
        }
    }
    fclose(fp);
    return dic;
}

- (void)compareAnalysis {
    
    for (NSString *path in self.resourceDate.allKeys) {
        NSDictionary *resourceDic = [self.resourceDate objectForKey:path];
        NSDictionary *excelDic = [self.excelData objectForKey:[self.resourceUrlMark objectForKey:path]];
        for (NSString *pathSub in resourceDic.allKeys) {
            
            NSMutableString *string = [NSMutableString string];
            
            NSDictionary *dic = [resourceDic objectForKey:pathSub];
            
            for (NSString *languageKey in dic.allKeys) {
                //对比key
                if ([excelDic.allKeys containsObject:languageKey]) {
                    
                    NSString *language = [NSString stringWithFormat:@"%@ = %@",languageKey,[excelDic objectForKey:languageKey]];
                    [string appendFormat:@"%@; \n",language];
                } else {
                    //key缺失的情况处理，自动补全
                    NSString *language = [NSString stringWithFormat:@"%@ = %@",languageKey,[dic objectForKey:languageKey]];
                    [string appendFormat:@"%@ \n",language];
                    
                    NSString *error = self.textView.string;
                    NSString *errorStr = [error stringByAppendingString:[NSString stringWithFormat:@"没有找到key : %@ \n",languageKey]];
                    self.textView.string = errorStr;
                }
            }
            
            if (string.length > 0) {
                // 如果有值，就写入文件中（比如德语路径 de.lproj/Localizable.strings）
                FILE *fp = fopen([pathSub UTF8String], "w");
                if (fp) {
                    fprintf(fp, "%s", (const char *)[string UTF8String]);
                    fclose(fp);
                }
                
            }
        }
    }

    NSAlert *alert = [[NSAlert alloc]init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"任务已完成"];
    
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
    }];
}

#pragma mark - 2、解析Excel数据 转化成 字典

- (void)excelData:(NSString *)url {

    LAWExcelTool *tool = [LAWExcelTool shareInstance];
    tool.delegate = self;
    [tool parserExcelWithPath:url];

}


#pragma mark - LAWExcelParserDelegate

- (void)parser:(LAWExcelTool *)parser success:(id)responseObj {
    self.excelData = [NSDictionary dictionaryWithDictionary:(NSDictionary *)responseObj];
}

#pragma mark - Lazy load

- (NSDictionary *)InfoDic {
    if (!_InfoDic) {
        _InfoDic = @{
                    // (key)工程多语言文件名:(value)Excel表格中多语言标识key
                     @"Base.lproj":@"English",
                     @"cs.lproj":@"Czech(捷克)",
                     @"de.lproj":@"German",
                     @"en.lproj":@"English",
                     @"es.lproj":@"西班牙语",
                     @"fi.lproj":@"Finnish(芬兰)",
                     @"fr.lproj":@"法语",
                     @"he.lproj":@"Hebrew (עברית(",
                     @"id.lproj":@"Indonesian",
                     @"it.lproj":@"Italian",
                     @"ja.lproj":@"Japanese",
                     @"ko.lproj":@"韩语",
                     @"nb.lproj":@"Norwegian",
                     @"nl.lproj":@"Dutch",
                     @"pl.lproj":@"Polski",
                     @"pt-BR.lproj":@"Portuguese(巴西)",
                     @"pt-PT.lproj":@"Portuguese(葡萄牙)",
                     @"ro.lproj":@"Romanian(罗马尼亚)",
                     @"ru.lproj":@"Russian(俄语)",
                     @"sv.lproj":@"Swedish(瑞典语)",
                     @"tr.lproj":@"Turkish(土耳其语)",
                     @"zh-Hans.lproj":@"中文",
                     @"zh-Hant.lproj":@"中文繁体"
                     };
    }
    return _InfoDic;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
