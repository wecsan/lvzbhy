import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hot_live/model/livearea.dart';
import 'package:hot_live/pages/areas/areas_room.dart';
import 'package:hot_live/widgets/keep_alive_wrapper.dart';

class AreaCard extends StatelessWidget {
  const AreaCard({
    Key? key,
    required this.area,
  }) : super(key: key);

  final AreaInfo area;

  void onTap(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AreasRoomPage(area: area)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeepAliveWrapper(
      child: Card(
        margin: const EdgeInsets.all(7.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () => onTap(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Card(
                  margin: const EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  color: Theme.of(context).focusColor,
                  elevation: 0,
                  child: CachedNetworkImage(
                    imageUrl: area.areaPic,
                    fit: BoxFit.fill,
                    errorWidget: (context, error, stackTrace) => const Center(
                      child: Text(
                        'Cover\nNot Found',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                title: Text(
                  area.areaName,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      area.typeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      area.platform.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
