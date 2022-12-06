import 'package:dd_study_ui/data/services/auth_service.dart';
import 'package:flutter/material.dart';

import 'app_navigator.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _counter = 0;
  bool _showFab = true;
  bool _showNotch = true;
  final _authService = AuthService();
  FloatingActionButtonLocation _fablocation = 
    FloatingActionButtonLocation.endDocked;

    void _onShowNotchChanged(bool value)
    {
      setState(() {
        _showNotch = value;
      });
    }

    void _onShowFabChanged(bool value)
    {
      setState(() {
        _showFab = value;
      });
    }

    void _onFabLocationChanged(FloatingActionButtonLocation? loc)
    {
      setState(() {
        _fablocation = loc ?? FloatingActionButtonLocation.centerDocked;
      });
    }
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
  void _logout()
  {
    _authService.logout().then((value) => AppNavigator.toLoader());
  }

 

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      floatingActionButtonLocation: _fablocation ,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("${widget.title} - $_counter"),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.exit_to_app)),
        ],
      ),
      body: 
      ListView(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5,),
      children: [
        SwitchListTile(onChanged:  _onShowNotchChanged,
        value: _showNotch,
        title: const Text("Notch"),),
        SwitchListTile(onChanged: _onShowFabChanged,
        value: _showFab,
        title: const Text("Fab enable"),
        ),
        const Divider(),
        const Padding(padding: EdgeInsets.all(10), 
        child: Text("Fab location"), 
        ),
        RadioListTile(title: const Text("centerDocked"),value: FloatingActionButtonLocation.centerDocked, groupValue: _fablocation, onChanged: _onFabLocationChanged),
        RadioListTile(title: const Text("endDocked"),value: FloatingActionButtonLocation.endDocked, groupValue: _fablocation, onChanged: _onFabLocationChanged),
        RadioListTile(title: const Text("endFloat"),value: FloatingActionButtonLocation.endFloat, groupValue: _fablocation, onChanged: _onFabLocationChanged),
        RadioListTile(title: const Text("centerFloat"),value: FloatingActionButtonLocation.centerFloat, groupValue: _fablocation, onChanged: _onFabLocationChanged),

        
      ],
      ),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
      floatingActionButton: _showFab? Wrap(children: [
        FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.access_alarm),
      ),
      //FloatingActionButton(
      //  onPressed: _incrementCounter,
      //  tooltip: 'Increment',
      //  child: const Icon(Icons.access_alarm),
      // )
      ],
      
      ) : null,
      bottomNavigationBar: _BottomAppBarTest(fabLocation: _fablocation, shape: _showNotch ? CircularNotchedRectangle() : null,),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class _BottomAppBarTest extends StatelessWidget{
  _BottomAppBarTest({ required this.fabLocation, this.shape});

   void _showLoader()
  {
    AppNavigator.toLoader();
  }

  final FloatingActionButtonLocation fabLocation;
  final CircularNotchedRectangle? shape;
  final List<FloatingActionButtonLocation> centerVariants = [FloatingActionButtonLocation.centerDocked, FloatingActionButtonLocation.centerFloat,FloatingActionButtonLocation.endDocked, FloatingActionButtonLocation.endFloat];
@override 
Widget build(BuildContext context){
  return BottomAppBar(shape: shape, color: Colors.indigo, child:
  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(icon: const Icon(Icons.menu), onPressed: (){},),
      IconButton(icon: const Icon(Icons.favorite), onPressed: (){},)
    ],
  ) );
}
}


