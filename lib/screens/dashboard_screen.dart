import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/baby.dart';
import '../store/baby_store.dart';
import '../widgets/action_button.dart';
import '../widgets/activity_row.dart';
import 'add_baby_screen.dart';
import 'feeding_entry_screen.dart';
import 'diaper_entry_screen.dart';
import 'sleep_entry_screen.dart';
import 'health_entry_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Baby? _activeBaby;

  void _openSheet(BuildContext context, Baby baby, String type) {
    Widget screen;
    switch (type) {
      case 'Feeding':
        screen = FeedingEntryScreen(baby: baby);
        break;
      case 'Diaper':
        screen = DiaperEntryScreen(baby: baby);
        break;
      case 'Sleep':
        screen = SleepEntryScreen(baby: baby);
        break;
      case 'Health':
        screen = HealthEntryScreen(baby: baby);
        break;
      default:
        return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => screen,
    );
  }

  void _openAddBaby(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddBabyScreen(onAdded: (baby) {
        setState(() => _activeBaby = baby);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<BabyStore>();
    final babies = store.babies;

    if (_activeBaby == null && babies.isNotEmpty) {
      _activeBaby = babies.first;
    }

    if (babies.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add_outlined, size: 64, color: Color(0xFFCCCCCC)),
                const SizedBox(height: 20),
                const Text(
                  'No Babies Tracked',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Add your first baby to start tracking.',
                  style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _openAddBaby(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Add Baby', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final baby = _activeBaby ?? babies.first;
    final entries = store.entriesForBaby(baby.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baby selector row
                    if (babies.length > 1)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: babies.map((b) {
                            final isActive = b.id == baby.id;
                            return GestureDetector(
                              onTap: () => setState(() => _activeBaby = b),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8, bottom: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  b.name,
                                  style: TextStyle(
                                    color: isActive ? Colors.white : const Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    // Profile card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                baby.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                baby.name,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Born: ${DateFormat('MMM d, yyyy').format(baby.birthDate)}',
                                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.person_add_outlined, color: Color(0xFF64748B)),
                            onPressed: () => _openAddBaby(context),
                            tooltip: 'Add baby',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.6,
                      children: [
                        ActionButton(
                          title: 'Feeding',
                          icon: Icons.water_drop_outlined,
                          color: const Color(0xFFF59E0B),
                          onPressed: () => _openSheet(context, baby, 'Feeding'),
                        ),
                        ActionButton(
                          title: 'Diaper',
                          icon: Icons.change_circle_outlined,
                          color: const Color(0xFF10B981),
                          onPressed: () => _openSheet(context, baby, 'Diaper'),
                        ),
                        ActionButton(
                          title: 'Sleep',
                          icon: Icons.bedtime_outlined,
                          color: const Color(0xFF6366F1),
                          onPressed: () => _openSheet(context, baby, 'Sleep'),
                        ),
                        ActionButton(
                          title: 'Health',
                          icon: Icons.favorite_outline,
                          color: const Color(0xFFEF4444),
                          onPressed: () => _openSheet(context, baby, 'Health'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Recent Activity',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            if (entries.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'No activities recorded yet.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = entries[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          ActivityRow(
                            entry: entry,
                            onDelete: () => context.read<BabyStore>().deleteEntry(entry.id),
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        ],
                      ),
                    );
                  },
                  childCount: entries.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
