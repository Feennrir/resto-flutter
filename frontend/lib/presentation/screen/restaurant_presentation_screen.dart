import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:restaurant_menu/viewmodels/restaurant_presentation_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'menu_screen.dart';
import '../../utils/colors.dart' as app_colors;

class RestaurantPresentationScreen extends StatefulWidget {
  const RestaurantPresentationScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantPresentationScreen> createState() => _RestaurantPresentationScreenState();
}

class _RestaurantPresentationScreenState extends State<RestaurantPresentationScreen> {
  static const LatLng defaultLocation = LatLng(45.761788, 4.833056); // Lyon, France
  final RestaurantPresentationViewModel viewModel = RestaurantPresentationViewModel();
  final String restaurantId = '1';
  late Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = viewModel.loadRestaurantInfo(restaurantId);
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: CupertinoPageScaffold(
        child: SafeArea(
          top: false,
          child: FutureBuilder<void>(
            future: _loadingFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CupertinoActivityIndicator(radius: 20),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.exclamationmark_triangle,
                          size: 64,
                          color: CupertinoColors.systemRed,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Erreur de chargement',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroSection(),
                          _buildRestaurantInfo(),
                          _buildLocationInfo(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  _buildFixedMenuButton(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openInAppleMaps() async {
    final restaurantInfo = viewModel.restaurantInfo.value;

    // Utiliser les coordonnées de la base de données ou les coordonnées par défaut
    final LatLng location = restaurantInfo?.latitude != null && restaurantInfo?.longitude != null
        ? LatLng(restaurantInfo!.latitude!, restaurantInfo.longitude!)
        : defaultLocation;

    final String address = restaurantInfo?.address ?? '15 Rue de la Gastronomie, 75001 Paris, France';
    final String restaurantName = restaurantInfo?.name ?? 'Le Gourmet';

    // URL pour Apple Maps avec coordonnées et nom du restaurant
    final Uri appleMapsUrl = Uri.parse(
        'https://maps.apple.com/?ll=${location.latitude},${location.longitude}&q=${Uri.encodeComponent(restaurantName)}&address=${Uri.encodeComponent(address)}'
    );

    try {
      if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback vers Google Maps si Apple Maps n'est pas disponible
        final Uri googleMapsUrl = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}'
        );

        if (await canLaunchUrl(googleMapsUrl)) {
          await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            _showErrorDialog('Impossible d\'ouvrir l\'application de cartes');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erreur lors de l\'ouverture de la carte : $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeroSection() {
    final restaurantInfo = viewModel.restaurantInfo.value;
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            restaurantInfo?.imageUrl ?? 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800'
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CupertinoColors.black.withValues(alpha: 0.3),
              CupertinoColors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurantInfo?.name ?? 'Le Gourmet',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Restaurant Gastronomique Français',
                style: TextStyle(
                  fontSize: 18,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    final restaurantInfo = viewModel.restaurantInfo.value;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notre Histoire',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            restaurantInfo?.description ?? 
            'Depuis 1985, Le Gourmet vous accueille dans un cadre élégant et chaleureux. Notre chef, formé dans les plus grandes maisons françaises, vous propose une cuisine raffinée mêlant tradition et modernité.\n\nNous privilégions les produits frais et de saison, travaillant exclusivement avec des producteurs locaux pour vous offrir le meilleur de la gastronomie française.',
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          if (restaurantInfo != null) ...[
            _buildInfoRow(
              CupertinoIcons.time,
              'Horaires',
              restaurantInfo.formattedHours,
              false
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              CupertinoIcons.person_2_fill,
              'Capacité',
              '${restaurantInfo.maxCapacity} places',
              false
            ),
            const SizedBox(height: 12),
            if (restaurantInfo.phone != null) ...[
              _buildInfoRow(CupertinoIcons.phone, 'Réservations', restaurantInfo.phone!, true),
              const SizedBox(height: 12),
            ],
          ] else ...[
            _buildInfoRow(CupertinoIcons.time, 'Horaires', 'Mar-Dim : 12h-14h / 19h-22h', false),
            const SizedBox(height: 12),
            _buildInfoRow(CupertinoIcons.phone, 'Réservations', '+33 1 42 86 87 88', true),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, bool isPhoneNumber) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: app_colors.Colors.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 4),
              isPhoneNumber
                  ? GestureDetector(
                onTap: () => _makePhoneCall(value),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: app_colors.Colors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
                  : Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Nettoyer le numéro de téléphone (enlever espaces, tirets, etc.)
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri phoneUri = Uri.parse('tel:$cleanNumber');

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          _showErrorDialog('Impossible d\'ouvrir l\'application téléphone');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erreur lors de l\'appel : $e');
      }
    }
  }

  Widget _buildLocationInfo() {
    final restaurantInfo = viewModel.restaurantInfo.value;
    // Utiliser les coordonnées de la base de données ou les coordonnées par défaut
    final LatLng restaurantLocation = restaurantInfo?.latitude != null && restaurantInfo?.longitude != null
        ? LatLng(restaurantInfo!.latitude!, restaurantInfo.longitude!)
        : defaultLocation;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.location_solid,
                color: app_colors.Colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Adresse',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            restaurantInfo?.address ?? '15 Rue de la Gastronomie\n75001 Paris, France',
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 16),
          // Carte interactive avec geste de tap
          GestureDetector(
            onTap: _openInAppleMaps,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: CupertinoColors.systemGrey4,
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: restaurantLocation,
                        initialZoom: 16.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none, // Désactiver les interactions pour permettre le tap
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.restaurant_menu',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: restaurantLocation,
                              width: 40,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: app_colors.Colors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: CupertinoColors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: CupertinoColors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  CupertinoIcons.location_solid,
                                  color: CupertinoColors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Overlay pour indiquer que la carte est cliquable
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.map,
                            color: CupertinoColors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Ouvrir dans Plans',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Métro : Châtelet-Les Halles (Lignes 1, 4, 7, 11, 14)\nParking : Parking Samaritaine (5 min à pied)',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey2,
            ),
          ),
          const SizedBox(height: 12),
          // Bouton alternatif pour ouvrir la carte
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.location_circle,
                  color: app_colors.Colors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Obtenir l\'itinéraire',
                  style: TextStyle(
                    color: app_colors.Colors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            onPressed: _openInAppleMaps,
          ),
        ],
      ),
    );
  }

  Widget _buildFixedMenuButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoButton.filled(
          borderRadius: BorderRadius.circular(12),
          child: const Text(
            'Découvrir notre Menu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => const MenuScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

}
