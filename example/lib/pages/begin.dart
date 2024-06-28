import 'package:flutter/material.dart';
import 'package:flutter_map_example/pages/home.dart';
import 'package:flutter_map_example/pages/login.dart';
import 'package:flutter_map_example/pages/profile_screen.dart';
import 'package:flutter_svg/svg.dart';

Future<void> showIntroduce(BuildContext context) {
  final double screenWidth = MediaQuery.of(context).size.width;
  return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 360,
          width: screenWidth,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          color: Colors.white30,
          child: Column(
            children: [
              const Text(
                'Mang lại sự tiện lợi khi đến thành phố Nha Trang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Mang lại sự tiện lợi khi đến thành phố Nha Trang, Mang lại sự tiện lợi khi đến thành phố Nha Trang, Mang lại sự tiện lợi khi đến thành phố Nha Trang.',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, HomePage.route);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 167, 111),
                  minimumSize: Size(screenWidth, 60),
                ),
                child: const Text(
                  'Nhấn để bắt đầu',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        );
      });
}

class BeginPage extends StatefulWidget {
  static const String route = '/begin';

  const BeginPage({super.key});

  @override
  State<BeginPage> createState() => _BeginState();
}

class _BeginState extends State<BeginPage> {
  int _selectedIndex = 0;
  List<int> loadedPages = [0];

  void _onItemTapped(int index) {
    final pages = loadedPages;
    if (!pages.contains(index)) {
      pages.add(index);
    }
    setState(() {
      _selectedIndex = index;
      loadedPages = pages;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomePage(),
      loadedPages.contains(1) ? const Login() : Container(),
      loadedPages.contains(2) ? const HomePage() : Container(),
      loadedPages.contains(3) ? const Login() : Container(),
      loadedPages.contains(4) ? const ProfileScreen() : Container(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/bottom_navigator/ic_home.svg',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset('assets/bottom_navigator/ic_home.svg',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/bottom_navigator/ic_list_order.svg',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset(
                'assets/bottom_navigator/ic_list_order.svg',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
            label: 'My Order',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/bottom_navigator/ic_map.svg',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset('assets/bottom_navigator/ic_map.svg',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/bottom_navigator/ic_message.svg',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset(
                'assets/bottom_navigator/ic_message.svg',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/bottom_navigator/ic_profile.svg',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
            activeIcon: SvgPicture.asset(
                'assets/bottom_navigator/ic_profile.svg',
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
