import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class AnimatedNavigationSwitch extends StatefulWidget {
  // Этот параметр нужен, чтобы на странице кошельков свитч сразу был в правом положении
  final bool initialIsCards; 

  const AnimatedNavigationSwitch({
    super.key,
    this.initialIsCards = true,
  });

  @override
  State<AnimatedNavigationSwitch> createState() => _AnimatedNavigationSwitchState();
}

class _AnimatedNavigationSwitchState extends State<AnimatedNavigationSwitch> {
  late bool _isCardsActive;

  @override
  void initState() {
    super.initState();
    _isCardsActive = widget.initialIsCards;
  }

  void _toggleSwitch(bool isCards) {
    if (_isCardsActive == isCards) return; // Если нажали на уже активную, ничего не делаем

    setState(() {
      _isCardsActive = isCards;
    });

    // Даем 150 миллисекунд на то, чтобы ползунок начал визуально уезжать, прежде чем сменится экран
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      
      if (isCards) {
        context.go('/home_cards'); // Замени на нужный роут для Home_card, если он другой
      } else {
        context.go('/home_wallets');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Вычисляем размеры из твоих исходных паддингов (25 гориз, 15 верт) и высоты иконки (26)
    // 25 + 26 + 25 ≈ 76 (ширина одной зоны клика)
    // 15 + 26 + 15 = 56 (высота)
    const double buttonWidth = 76.0; 
    const double buttonHeight = 56.0;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SizedBox(
        width: buttonWidth * 2, // Общая ширина для двух кнопок
        height: buttonHeight,
        child: Stack(
          children: [
            // 1. АНИМИРОВАННЫЙ ПОЛЗУНОК (ФОН)
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              alignment: _isCardsActive ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: buttonWidth,
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(34),
                ),
              ),
            ),

            // 2. ИКОНКИ (лежат поверх ползунка)
           Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Кнопка: Карты
              GestureDetector(
                onTap: () => _toggleSwitch(true),
                behavior: HitTestBehavior.opaque, 
                child: SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: Center(
                    child: SvgPicture.asset(
                      // Если активно -> card_active.svg, иначе -> обычная card.svg
                      _isCardsActive 
                          ? 'assets/images/card_active.svg' 
                          : 'assets/images/card.svg', // Проверь, как точно называется твой неактивный файл карт
                      height: 26,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.credit_card,
                        color: _isCardsActive ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),

              // Кнопка: Кошельки
              GestureDetector(
                onTap: () => _toggleSwitch(false),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: Center(
                    child: SvgPicture.asset(
                      // Если НЕ активны карты (т.е. активны кошельки) -> wallet_active.svg, иначе -> wallet.svg
                      !_isCardsActive 
                          ? 'assets/images/wallet_active.svg' 
                          : 'assets/images/wallet.svg', 
                      height: 26,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.account_balance_wallet_outlined,
                        color: !_isCardsActive ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
          ],
        ),
      ),
    );
  }
}