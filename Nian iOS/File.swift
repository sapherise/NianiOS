//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
////        CGRect rect = [_data[@"frame"] CGRectValue];
////        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
////        CGContextRef context = UIGraphicsGetCurrentContext();
////        [[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1] set];
////        CGContextFillRect(context, rect);
////        if ([_data valueForKey:@"subData"]) {
////            [[UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1] set];
////            CGRect subFrame = [_data[@"subData"][@"frame"] CGRectValue];
////            CGContextFillRect(context, subFrame);
////            [[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1] set];
////            CGContextFillRect(context, CGRectMake(0, subFrame.origin.y, rect.size.width, .5));
////        }
//        
//        {
////            float leftX = SIZE_GAP_LEFT+SIZE_AVATAR+SIZE_GAP_BIG;
////            float x = leftX;
////            float y = (SIZE_AVATAR-(SIZE_FONT_NAME+SIZE_FONT_SUBTITLE+6))/2-2+SIZE_GAP_TOP+SIZE_GAP_SMALL-5;
////            [_data[@"name"] drawInContext:context withPosition:CGPointMake(x, y) andFont:FontWithSize(SIZE_FONT_NAME)
////                andTextColor:[UIColor colorWithRed:106/255.0 green:140/255.0 blue:181/255.0 alpha:1]
////                andHeight:rect.size.height];
////            y += SIZE_FONT_NAME+5;
////            float fromX = leftX;
////            float size = [UIScreen screenWidth]-leftX;
////            NSString *from = [NSString stringWithFormat:@"%@  %@", _data[@"time"], _data[@"from"]];
////            [from drawInContext:context withPosition:CGPointMake(fromX, y) andFont:FontWithSize(SIZE_FONT_SUBTITLE)
////            andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1]
////            andHeight:rect.size.height andWidth:size];
////            }
//            
////            {
////                CGRect countRect = CGRectMake(0, rect.size.height-30, [UIScreen screenWidth], 30);
////                [[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1] set];
////                CGContextFillRect(context, countRect);
////                float alpha = 1;
////                
////                float x = [UIScreen screenWidth]-SIZE_GAP_LEFT-10;
////                NSString *comments = _data[@"comments"];
////                if (comments) {
////                    CGSize size = [comments sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:FontWithSize(SIZE_FONT_SUBTITLE) lineSpace:5];
////                    
////                    x -= size.width;
////                    [comments drawInContext:context withPosition:CGPointMake(x, 8+countRect.origin.y)
////                        andFont:FontWithSize(12)
////                        andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1]
////                        andHeight:rect.size.height];
////                    [[UIImage imageNamed:@"t_comments.png"] drawInRect:CGRectMake(x-5, 10.5+countRect.origin.y, 10, 9) blendMode:kCGBlendModeNormal alpha:alpha];
////                    commentsRect = CGRectMake(x-5, self.height-50, [UIScreen screenWidth]-x+5, 50);
////                    x -= 20;
////                }
////                
////                NSString *reposts = _data[@"reposts"];
////                if (reposts) {
////                    CGSize size = [reposts sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:FontWithSize(SIZE_FONT_SUBTITLE) lineSpace:5];
////                    
////                    x -= MAX(size.width, 5)+SIZE_GAP_BIG;
////                    [reposts drawInContext:context withPosition:CGPointMake(x, 8+countRect.origin.y)
////                        andFont:FontWithSize(12)
////                        andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1]
////                        andHeight:rect.size.height];
////                    
////                    [[UIImage imageNamed:@"t_repost.png"] drawInRect:CGRectMake(x-5, 11+countRect.origin.y, 10, 9) blendMode:kCGBlendModeNormal alpha:alpha];
////                    repostsRect = CGRectMake(x-5, self.height-50, commentsRect.origin.x-x, 50);
////                    x -= 20;
////                }
////                
////                [@"•••" drawInContext:context
////                withPosition:CGPointMake(SIZE_GAP_LEFT, 8+countRect.origin.y)
////                andFont:FontWithSize(11)
////                andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:.5]
////                andHeight:rect.size.height];
////                
////                if ([_data valueForKey:@"subData"]) {
////                    [[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1] set];
////                    CGContextFillRect(context, CGRectMake(0, rect.size.height-30.5, rect.size.width, .5));
////                }
////        }
//        
//        UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (flag==drawColorFlag) {
//                postBGView.frame = rect;
//                postBGView.image = nil;
//                postBGView.image = temp;
//            }
//            });
//        });
//    [self drawText];
//    [self loadThumb];
//}