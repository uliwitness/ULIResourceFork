//
//  ULIResourceForkStream.h
//  ULIResourceForkReader
//
//  Created by Uli Kusterer on 03.05.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import "ULIStream.h"


NS_ASSUME_NONNULL_BEGIN

@interface ULIInputStream (ULIResourceForkStream)

+ (nullable instancetype)inputStreamForResourceForkWithURL: (NSURL *)url;

@end

NS_ASSUME_NONNULL_END
