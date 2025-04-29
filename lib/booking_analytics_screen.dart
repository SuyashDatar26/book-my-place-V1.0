import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:collection';

class BookingAnalyticsScreen extends StatefulWidget {
  const BookingAnalyticsScreen({super.key});

  @override
  State<BookingAnalyticsScreen> createState() => _BookingAnalyticsScreenState();
}

class _BookingAnalyticsScreenState extends State<BookingAnalyticsScreen> {
  int totalBookings = 0;
  int totalVenues = 0;
  Map<String, int> bookingsPerDay = {};
  Map<String, int> bookingsPerVenue = {};

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    final bookingsSnapshot = await FirebaseFirestore.instance.collection(
        'bookings').get();
    final venueSnapshot = await FirebaseFirestore.instance.collection(
        'resources').get();

    Map<String, int> tempBookingsPerDay = {};
    Map<String, int> tempBookingsPerVenue = {};

    print('Bookings fetched: ${bookingsSnapshot.docs.length}');
    for (var doc in bookingsSnapshot.docs) {
      final data = doc.data();
      print('Booking: ${data}');

      try {
        Timestamp timestamp = data['date'];
        final date = timestamp.toDate();
        final dayString = "${date.year}-${date.month}-${date.day}";
        tempBookingsPerDay.update(
            dayString, (value) => value + 1, ifAbsent: () => 1);
      } catch (e) {
        print('Error parsing date: $e');
      }

      try {
        final venueId = data['venueId'] ?? 'Unknown';
        tempBookingsPerVenue.update(
            venueId, (value) => value + 1, ifAbsent: () => 1);
      } catch (e) {
        print('Error parsing venueId: $e');
      }
    }

    setState(() {
      totalBookings = bookingsSnapshot.size;
      totalVenues = venueSnapshot.size;
      bookingsPerDay = SplayTreeMap.from(tempBookingsPerDay); // Sorted by date
      bookingsPerVenue = tempBookingsPerVenue;
    });

    print('Bookings per day: $bookingsPerDay');
    print('Bookings per venue: $bookingsPerVenue');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Analytics'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _analyticsCard('Total Bookings', totalBookings),
            _analyticsCard('Total Venues', totalVenues),
            const SizedBox(height: 20),
            const Text('Bookings Over Time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(height: 250, child: LineChart(_buildLineChartData())),
            const SizedBox(height: 30),
            const Text('Bookings Per Venue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(height: 250, child: BarChart(_buildBarChartData())),
          ],
        ),
      ),
    );
  }

  Widget _analyticsCard(String label, int value) {
    return Card(
      color: Colors.deepPurple[50],
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.analytics, color: Colors.deepPurple),
        title: Text(label),
        trailing: Text('$value',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  LineChartData _buildLineChartData() {
    final spots = <FlSpot>[];
    int x = 0;
    for (var entry in bookingsPerDay.entries) {
      spots.add(FlSpot(x.toDouble(), entry.value.toDouble()));
      x++;
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) =>
            FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < bookingsPerDay.keys.length) {
                return Text(
                  bookingsPerDay.keys.elementAt(index),
                  style: const TextStyle(fontSize: 10),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: 1,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(color: Colors.black12),
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      minX: 0,
      maxX: spots.length.toDouble() - 1,
      minY: 0,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: const LinearGradient(
            colors: [Color(0xFF7E57C2), Color(0xFF512DA8)],
          ),
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [Colors.deepPurple.withOpacity(0.3), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 3,
                  color: Colors.deepPurple,
                  strokeColor: Colors.white,
                ),
          ),
        ),
      ],
    );
  }

  BarChartData _buildBarChartData() {
    final barGroups = <BarChartGroupData>[];
    int x = 0;
    for (var entry in bookingsPerVenue.entries.take(6)) {
      barGroups.add(
        BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: entry.value.toDouble(),
              gradient: const LinearGradient(
                colors: [Color(0xFF9575CD), Color(0xFF512DA8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              width: 18,
              borderRadius: BorderRadius.circular(8),
            )
          ],
        ),
      );
      x++;
    }

    return BarChartData(
      barGroups: barGroups,
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) =>
            FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < bookingsPerVenue.keys.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    bookingsPerVenue.keys.elementAt(index),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(color: Colors.black12),
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      alignment: BarChartAlignment.spaceAround,
      maxY: (bookingsPerVenue.values.reduce((a, b) => a > b ? a : b) + 1)
          .toDouble(),
    );
  }
}