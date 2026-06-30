import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/subscription_plan.dart';
import '../../services/subscription_service.dart';
import '../../widgets/vaano_logo.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlan = 1;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Vaanologo(size: 72, showText: false, hasBackground: true),
                  const SizedBox(height: 16),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Color(0xFFF2D06B), Color(0xFFFFE4A0)],
                    ).createShader(bounds),
                    child: const Text('VAÀNO Premium',
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Georgia')),
                  ),
                  const SizedBox(height: 8),
                  Text('Unlock all features and AI tools',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(SubscriptionService.plans.length, (i) {
              final plan = SubscriptionService.plans[i];
              final isSelected = _selectedPlan == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedPlan = i),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : Border.all(color: Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(plan.name,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  )),
                                if (plan.isPopular) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.premium,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('BEST VALUE',
                                      style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(plan.price,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  )),
                                Text(plan.period,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Included Features:',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ...SubscriptionService.plans[_selectedPlan].features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.check, color: AppColors.success, size: 14),
                        ),
                        const SizedBox(width: 12),
                        Text(f, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    setState(() => _isLoading = true);
                    if (_selectedPlan == 0) {
                      Navigator.pop(context);
                    } else {
                      await SubscriptionService().purchasePremium();
                    }
                    if (mounted) {
                      setState(() => _isLoading = false);
                      if (_selectedPlan > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Welcome to vaáno Premium!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedPlan == 0 ? AppColors.cardLight : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _selectedPlan == 0 ? 'Continue with Free' : 'Subscribe Now',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
            if (_selectedPlan > 0) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                child: const Text('Restore Purchase',
                  style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
