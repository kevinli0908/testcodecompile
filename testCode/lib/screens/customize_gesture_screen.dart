import 'package:flutter/material.dart';
import '../models/gesture_model.dart';
import '../widgets/gesture_item_tile.dart';
import '../theme/app_theme.dart';

class CustomizeGestureScreen extends StatefulWidget {
  final List<GestureModel> gestures;
  final Function(List<GestureModel>) onGesturesUpdated;

  const CustomizeGestureScreen({
    super.key,
    required this.gestures,
    required this.onGesturesUpdated,
  });

  @override
  State<CustomizeGestureScreen> createState() => _CustomizeGestureScreenState();
}

class _CustomizeGestureScreenState extends State<CustomizeGestureScreen> {
  late List<GestureModel> _gestures;

  @override
  void initState() {
    super.initState();
    _gestures = List.from(widget.gestures);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Customize Gesture'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.purple.withOpacity(0.05),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.gesture,
                    color: Colors.purple,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How gesture customization works',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap on any gesture to assign or change its action',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _gestures.length,
              itemBuilder: (context, index) {
                return GestureItemTile(
                  gesture: _gestures[index],
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignActionScreen(
                          gesture: _gestures[index],
                        ),
                      ),
                    );
                    if (result != null && result is String) {
                      setState(() {
                        _gestures[index] = _gestures[index].copyWith(
                          assignedAction: result,
                        );
                      });
                    }
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onGesturesUpdated(_gestures);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gestures saved successfully!'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AssignActionScreen extends StatelessWidget {
  final GestureModel gesture;

  const AssignActionScreen({super.key, required this.gesture});

  final List<Map<String, dynamic>> availableActions = const [
    {'icon': Icons.camera_alt, 'name': 'Open Camera', 'color': Colors.blue},
    {'icon': Icons.flashlight_on, 'name': 'Flashlight', 'color': Colors.yellow},
    {'icon': Icons.volume_up, 'name': 'Volume Up', 'color': Colors.green},
    {'icon': Icons.volume_down, 'name': 'Volume Down', 'color': Colors.red},
    {'icon': Icons.skip_next, 'name': 'Next Track', 'color': Colors.purple},
    {'icon': Icons.skip_previous, 'name': 'Previous Track', 'color': Colors.orange},
    {'icon': Icons.play_arrow, 'name': 'Play/Pause', 'color': Colors.teal},
    {'icon': Icons.screenshot, 'name': 'Take Screenshot', 'color': Colors.indigo},
    {'icon': Icons.home, 'name': 'Go Home', 'color': Colors.grey},
    {'icon': Icons.notifications, 'name': 'Open Notifications', 'color': Colors.cyan},
    {'icon': Icons.settings, 'name': 'Open Settings', 'color': Colors.deepPurple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Assign Action for ${gesture.name}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blue.withOpacity(0.05),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    gesture.icon,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gesture.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gesture.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 20, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Select an action to assign to this gesture',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: availableActions.length,
              itemBuilder: (context, index) {
                final action = availableActions[index];
                final isSelected = gesture.assignedAction == action['name'];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (action['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: action['color'] as Color,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      action['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      Navigator.pop(context, action['name']);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GestureDetailScreen extends StatelessWidget {
  final GestureModel gesture;
  final int index;
  final Function(int, GestureModel) onGestureUpdated;

  const GestureDetailScreen({
    super.key,
    required this.gesture,
    required this.index,
    required this.onGestureUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(gesture.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        gesture.icon,
                        color: Colors.blue,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      gesture.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      gesture.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Action',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            gesture.assignedAction ?? 'Not assigned',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssignActionScreen(
                                  gesture: gesture,
                                ),
                              ),
                            );
                            if (result != null && result is String) {
                              final updatedGesture = gesture.copyWith(
                                assignedAction: result,
                              );
                              onGestureUpdated(index, updatedGesture);
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Change'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}