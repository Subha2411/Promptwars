import 'package:flutter/material.dart';

enum VenueType { stadium, mall, railwayStation }

class VenueConfig {
  final String id;
  final String name;
  final String subtitle;
  final VenueType type;
  final IconData icon;
  final String capacity;
  final String hintText;
  final String buttonText;

  const VenueConfig({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.type,
    required this.icon,
    required this.capacity,
    required this.hintText,
    required this.buttonText,
  });
}

class VenueRegistry {
  static const List<VenueConfig> allVenues = [
    VenueConfig(
      id: 'narendra_modi_stadium',
      name: 'Narendra Modi Stadium',
      subtitle: 'IPL 2026 Final',
      type: VenueType.stadium,
      icon: Icons.sports_cricket,
      capacity: '132,000',
      hintText: 'Enter Gate / Block (e.g. B-12)',
      buttonText: 'Enter Arena',
    ),
    VenueConfig(
      id: 'o2_arena',
      name: 'The O2 Arena',
      subtitle: 'Coldplay Global Tour',
      type: VenueType.stadium,
      icon: Icons.music_note,
      capacity: '20,000',
      hintText: 'Enter Gate / Block (e.g. B-12)',
      buttonText: 'Enter Arena',
    ),
    VenueConfig(
      id: 'phoenix_mall',
      name: 'Phoenix Marketcity',
      subtitle: 'Weekend Shopping Fest',
      type: VenueType.mall,
      icon: Icons.local_mall,
      capacity: '45,000',
      hintText: 'Enter your floor / wing (e.g. Ground, West)',
      buttonText: 'Navigate Mall',
    ),
    VenueConfig(
      id: 'grand_central_mall',
      name: 'Grand Central Mall',
      subtitle: 'Summer Sale',
      type: VenueType.mall,
      icon: Icons.store,
      capacity: '30,000',
      hintText: 'Enter your floor / wing (e.g. Ground, West)',
      buttonText: 'Navigate Mall',
    ),
    VenueConfig(
      id: 'howrah_station',
      name: 'Howrah Railway Station',
      subtitle: 'Peak Hour Transit',
      type: VenueType.railwayStation,
      icon: Icons.train,
      capacity: '80,000',
      hintText: 'Enter your platform or entry (e.g. Platform 1)',
      buttonText: 'Navigate Station',
    ),
    VenueConfig(
      id: 'grand_central_terminal',
      name: 'Grand Central Terminal',
      subtitle: 'Express Commutes',
      type: VenueType.railwayStation,
      icon: Icons.directions_railway,
      capacity: '125,000',
      hintText: 'Enter your platform or entry (e.g. Platform 1)',
      buttonText: 'Navigate Station',
    ),
  ];
}
