import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/hazmat_guide.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fade_slide_in.dart';

class HazmatTab extends StatefulWidget {
  const HazmatTab({super.key});

  @override
  State<HazmatTab> createState() => _HazmatTabState();
}

class _HazmatTabState extends State<HazmatTab> {
  final List<HazmatGuide> _guides = DummyData.hazmatGuides();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.dangerous_outlined, color: AppColors.danger),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Muatan B3 (Bahan Berbahaya & Beracun) wajib mengikuti '
                      'panduan berikut sebelum armada diberangkatkan.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 150),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ExpansionPanelList(
                elevation: 0,
                expandedHeaderPadding: EdgeInsets.zero,
                materialGapSize: 10,
                animationDuration: const Duration(milliseconds: 400),
                dividerColor: Colors.grey.shade200,
                expansionCallback: (index, isExpanded) {
                  setState(() => _guides[index].isExpanded = isExpanded);
                },
                children: _guides.map(_buildPanel).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ExpansionPanel _buildPanel(HazmatGuide guide) {
    return ExpansionPanel(
      canTapOnHeader: true,
      isExpanded: guide.isExpanded,
      backgroundColor: Colors.white,
      headerBuilder: (context, isExpanded) => ListTile(
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isExpanded
                ? guide.color
                : guide.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            guide.icon,
            color: isExpanded ? Colors.white : guide.color,
          ),
        ),
        title: Text(
          guide.title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        subtitle: Text('UN ${guide.unClass}'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            for (var i = 0; i < guide.rules.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: guide.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: guide.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        guide.rules[i],
                        style: const TextStyle(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
