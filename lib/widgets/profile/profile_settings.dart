import 'package:flutter/material.dart';
import 'settings_item.dart'; // ton widget SettingsItem

class ProfileSettings extends StatelessWidget {
  final bool isSeller;
  final Function(bool) updateSeller;
  final Future<void> Function() logout;
  final Future<void> Function() deleteAccount;

  const ProfileSettings({
    super.key,
    required this.isSeller,
    required this.updateSeller,
    required this.logout,
    required this.deleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            elevation: 7,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Paramètres du profil',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // ===== COMPTE =====
                  const Text(
                    'Compte',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SettingsItem(
                    title: 'Mode compte',
                    value: isSeller ? 'Vendeur' : 'Utilisateur',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder:
                            (_) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: const Text('Utilisateur'),
                                  trailing:
                                      !isSeller
                                          ? const Icon(Icons.check)
                                          : null,
                                  onTap: () {
                                    updateSeller(false);
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text('Vendeur'),
                                  trailing:
                                      isSeller ? const Icon(Icons.check) : null,
                                  onTap: () {
                                    updateSeller(true);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                  SettingsItem(title: 'Changer le mot de passe', onTap: () {}),

                  const SizedBox(height: 16),
                  const Text(
                    'Sécurité',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SettingsItem(title: 'Sécurité du compte', onTap: () {}),
                  SettingsItem(title: 'Connexions actives', onTap: () {}),
                  SettingsItem(
                    title: 'Authentification à deux facteurs',
                    value: 'Désactivée',
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SettingsItem(
                    title: 'Notifications',
                    value: 'Activées',
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Préférences',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SettingsItem(title: 'Thème', value: 'Clair', onTap: () {}),
                  SettingsItem(
                    title: 'Langue',
                    value: 'Français',
                    onTap: () {},
                  ),
                  SettingsItem(title: 'Région', value: 'Algérie', onTap: () {}),

                  const SizedBox(height: 16),
                  const Text(
                    'Légal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SettingsItem(title: 'À propos', onTap: () {}),
                  SettingsItem(title: 'Conditions d’utilisation', onTap: () {}),
                  SettingsItem(
                    title: 'Politique de confidentialité',
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SettingsItem(
                    title: 'Déconnexion',
                    color: Color.fromARGB(255, 255, 10, 88),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text("Déconnexion"),
                              content: const Text(
                                "Voulez-vous vraiment vous déconnecter ?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text("Annuler",style: TextStyle(color: Color.fromARGB(255, 0, 169, 191)),),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    "Déconnecter",
                                    style: TextStyle(color: Color.fromARGB(255, 255, 10, 88)),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        await logout();
                      }
                    },
                  ),
                  SettingsItem(
                    title: 'Supprimer le compte',
                    color: Color.fromARGB(255, 255, 10, 88),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text("Supprimer le compte"),
                              content: const Text(
                                "Voulez-vous vraiment supprimer votre compte ? Cette action est irréversible.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text("Annuler",style: TextStyle(color: Color.fromARGB(255, 0, 169, 191)),),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    "Supprimer",
                                    style: TextStyle(color: Color.fromARGB(255, 255, 10, 88)),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        await deleteAccount();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
