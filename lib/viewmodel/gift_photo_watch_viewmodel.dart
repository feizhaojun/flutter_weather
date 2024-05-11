import 'dart:async';

import 'package:flutter_weather/common/streams.dart';
import 'package:flutter_weather/model/data/mzi_data.dart';
import 'package:flutter_weather/model/holder/fav_holder.dart';
import 'package:flutter_weather/model/holder/shared_depository.dart';
import 'package:flutter_weather/utils/channel_util.dart';
import 'package:flutter_weather/viewmodel/viewmodel.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class GiftPhotoWatchViewModel<T> extends ViewModel {
  final favList = StreamController<List<MziItem>>();
  final data = StreamController<List<MziItem>>();

  GiftPhotoWatchViewModel({required Stream<List<MziItem>> photoStream}) {
    FavHolder().favMziStream!.listen((v) => favList.safeAdd(v)).bindLife(this as StreamSubController);

    photoStream.listen((v) => data.safeAdd(v)).bindLife(this as StreamSubController);
  
    favList.safeAdd(FavHolder().favMzis);
  }

  Future<bool> saveImage(String url) async {
    final savedImgs = SharedDepository().savedImages;
    if (savedImgs.contains(url)) {
      return false;
    }

    // final file = await DefaultCacheManager().getSingleFile(url);
    await SharedDepository().setSavedImages(savedImgs..add(url));
    // await ImageGallerySaver.saveImage(file.readAsBytesSync());

    return true;
    }

  Future<bool> setWallpaper(String url) async {
    // final file = await DefaultCacheManager().getSingleFile(url);
    final savedImgs = SharedDepository().savedImages;
    if (!savedImgs.contains(url)) {
      SharedDepository()
          .setSavedImages(SharedDepository().savedImages..add(url));
      // await ImageGallerySaver.saveImage(file.readAsBytesSync());
    }

    // ChannelUtil.setWallpaper(path: file.absolute.path);

    return true;
    }

  @override
  void dispose() {
    data.close();
    favList.close();

    super.dispose();
  }
}
