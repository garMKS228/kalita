import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';



class IOSNavigationSwitch extends StatefulWidget {
  final String path;
  final bool value; // Принимаем текущее значение извне
  final ValueChanged<bool> onChanged; // Принимаем функцию изменения

  const IOSNavigationSwitch({
    super.key,
    required this.path,
    required this.value,
    required this.onChanged,
  });

  @override
  State<IOSNavigationSwitch> createState() => _IOSNavigationSwitchState();
}

class _IOSNavigationSwitchState extends State<IOSNavigationSwitch> {
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.8,
      child: CupertinoSwitch(
        value: widget.value, // Берем значение из конструктора
        onChanged: (newValue) {
          widget.onChanged(newValue); // Сообщаем родителю, что свитч дернули
          context.push(widget.path);
        },
      ),
    );
  }
}
