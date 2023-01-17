import 'dart:async';

import 'package:dlna_dart/dlna.dart';
import 'package:flutter/material.dart';

class LiveDlnaPage extends StatefulWidget {
  final Map<String, Map<String, String>> streamList;

  const LiveDlnaPage({Key? key, required this.streamList}) : super(key: key);

  @override
  _LiveDlnaPageState createState() => _LiveDlnaPageState();
}

class _LiveDlnaPageState extends State<LiveDlnaPage> {
  final List<DLNADevice> _deviceList = [];
  final searcher = DLNAManager();
  String datasource = '';
  int selectDevice = -1;

  @override
  void initState() {
    datasource = widget.streamList.values.first.values.first;
    _searchDlnaDevice();
    super.initState();
  }

  void _searchDlnaDevice() async {
    final m = await searcher.start();
    m.devices.stream.listen((deviceList) {
      _deviceList.addAll(deviceList.values);
      setState(() {});
    });
    // close the server,the closed server can be start by call searcher.start()
    Timer(const Duration(seconds: 30), () {
      searcher.stop();
    });
    super.initState();
  }

  void _selectDevice(int index) {
    if (selectDevice != -1) _deviceList[selectDevice].pause();

    _deviceList[index].setUrl(datasource);
    _deviceList[index].play();
    setState(() {
      selectDevice = index;
    });
  }

  void _selectDatasource(String url) {
    setState(() {
      datasource = url;
    });
    _selectDevice(selectDevice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live DLNA')),
      body: Column(
        children: [
          _buildResolutionRow(),
          Expanded(
            child: ListView.builder(
              itemCount: _deviceList.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_deviceList[index].info.friendlyName),
                subtitle: Text(_deviceList[index].info.deviceType),
                onTap: () => _selectDevice(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionRow() {
    final List<Widget> resolutionBtns = [];
    widget.streamList.forEach((resolution, cdns) {
      final btn = PopupMenuButton(
        iconSize: 24,
        icon: Text(
          resolution.substring(resolution.length - 2, resolution.length),
          style: Theme.of(context).textTheme.labelMedium,
        ),
        onSelected: (String link) => _selectDatasource(link),
        itemBuilder: (context) {
          final menuList = <PopupMenuItem<String>>[];
          cdns.forEach((cdn, url) {
            final menuItem = PopupMenuItem<String>(
              child: Text(cdn, style: const TextStyle(fontSize: 14.0)),
              value: url,
            );
            menuList.add(menuItem);
          });
          return menuList;
        },
      );
      resolutionBtns.add(btn);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: resolutionBtns,
      ),
    );
  }
}
