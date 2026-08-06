import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/widgets/status_badge.dart';
import 'profile_provider.dart';

class DataPegawaiScreen extends StatelessWidget {
  const DataPegawaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider()..loadDetailPegawai(),
      child: const _DataPegawaiBody(),
    );
  }
}

class _DataPegawaiBody extends StatefulWidget {
  const _DataPegawaiBody();

  @override
  State<_DataPegawaiBody> createState() => _DataPegawaiBodyState();
}

class _DataPegawaiBodyState extends State<_DataPegawaiBody> {
  String _formatDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';
    try {
      final parsed = DateTime.parse(dateStr);
      return Formatters.tanggalPanjang(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _openDocument(BuildContext context, String? url, String docName) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berkas $docName tidak tersedia')),
      );
      return;
    }
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka dokumen ini secara otomatis')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saat membuka dokumen')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final d = provider.pegawaiDetail;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          title: const Text('Data Pegawai'),
          bottom: const TabBar(
            indicatorColor: AppColors.red,
            indicatorWeight: 3,
            labelColor: AppColors.red,
            unselectedLabelColor: AppColors.gray,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            tabs: [
              Tab(text: 'Personal'),
              Tab(text: 'Kepegawaian'),
              Tab(text: 'Dokumen'),
            ],
          ),
        ),
        body: provider.isLoadingDetail
            ? const _ShimmerLoading()
            : d == null
                ? EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Gagal memuat data pegawai',
                    subtitle: 'Terjadi kesalahan koneksi saat mengambil data.',
                    onRetry: () => provider.loadDetailPegawai(),
                  )
                : TabBarView(
                children: [
                  // Tab 1: Personal
                  RefreshIndicator(
                    color: AppColors.red,
                    onRefresh: () async => provider.loadDetailPegawai(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        children: [
                          FadeSlideIn(
                            child: _SectionCard(
                              title: 'Identitas Pribadi',
                              children: [
                                _InfoRow(label: 'Nama Lengkap (Tanpa Gelar)', value: d?.nama),
                                _InfoRow(label: 'Gelar Depan', value: d?.gelarDepan),
                                _InfoRow(label: 'Gelar Belakang', value: d?.gelarBelakang),
                                _InfoRow(label: 'Nama Panggilan', value: d?.namaPanggilan),
                                _InfoRow(label: 'Tempat Lahir', value: d?.tempatLahir),
                                _InfoRow(label: 'Tanggal Lahir', value: _formatDateString(d?.tanggalLahir)),
                                _InfoRow(
                                  label: 'Jenis Kelamin',
                                  value: d?.jenisKelamin == 'L'
                                      ? 'Laki-laki'
                                      : (d?.jenisKelamin == 'P' ? 'Perempuan' : null),
                                ),
                                _InfoRow(label: 'Golongan Darah', value: d?.golonganDarah),
                                _InfoRow(label: 'Agama', value: d?.agama),
                                _InfoRow(label: 'Status Pernikahan', value: d?.statusMarital),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeSlideIn(
                            index: 1,
                            child: _SectionCard(
                              title: 'Pendidikan Terakhir',
                              children: [
                                _InfoRow(label: 'Pendidikan Ringkasan', value: d?.pendidikanTerakhir),
                                _InfoRow(label: 'Jurusan Pendidikan', value: d?.jurusanPendidikan),
                                _InfoRow(label: 'Universitas / Lembaga Pendidikan', value: d?.universitas),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeSlideIn(
                            index: 2,
                            child: _SectionCard(
                              title: 'Kontak',
                              children: [
                                _InfoRow(label: 'Email Resmi', value: d?.email),
                                _InfoRow(label: 'Email Pribadi', value: d?.emailPribadi),
                                _InfoRow(label: 'No. HP Utama', value: d?.noHp),
                                _InfoRow(label: 'No. Telepon Tambahan/Kantor', value: d?.telepon),
                                _InfoRow(label: 'Fax', value: d?.fax),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeSlideIn(
                            index: 3,
                            child: _SectionCard(
                              title: 'Alamat Lengkap',
                              children: [
                                _InfoRow(label: 'Alamat Lengkap', value: d?.alamat),
                                _InfoRow(label: 'Koordinat Domisili WFH', value: d?.koordinatDomisili),
                                _InfoRow(label: 'Kelurahan', value: d?.kelurahan),
                                _InfoRow(label: 'Kecamatan', value: d?.kecamatan),
                                _InfoRow(label: 'Kota / Kabupaten', value: d?.kota),
                                _InfoRow(label: 'Provinsi', value: d?.provinsi),
                                _InfoRow(label: 'Kode Pos', value: d?.kodePos),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Tab 2: Kepegawaian
                  RefreshIndicator(
                    color: AppColors.red,
                    onRefresh: () async => provider.loadDetailPegawai(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        children: [
                          FadeSlideIn(
                            child: _SectionCard(
                              title: 'Kedudukan & Status Dinas',
                              children: [
                                _InfoRow(label: 'NIP', value: d?.nip),
                                _InfoRow(label: 'Tipe Pegawai', value: d?.tipePegawai),
                                _InfoRow(label: 'Status Kepegawaian', value: d?.statusKepegawaian),
                                _InfoRow(
                                  label: 'Status Aktif',
                                  customValue: d?.statusAktif != null
                                      ? StatusBadge(
                                          label: d!.statusAktif.toUpperCase(),
                                          tone: d.statusAktif == 'aktif' ? BadgeTone.success : BadgeTone.neutral,
                                        )
                                      : const Text('—', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeSlideIn(
                            index: 1,
                            child: _SectionCard(
                              title: 'Jabatan & Unit Kerja',
                              children: [
                                _InfoRow(label: 'Jabatan Utama', value: d?.jabatan),
                                _InfoRow(label: 'Unit Kerja', value: d?.unit),
                                _InfoRow(label: 'Atasan Langsung', value: d?.atasan),
                                _InfoRow(label: 'Jabatan PLT', value: d?.jabatanPlt),
                                _InfoRow(label: 'Jabatan PLH', value: d?.jabatanPlh),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeSlideIn(
                            index: 2,
                            child: _SectionCard(
                              title: 'Riwayat Kepangkatan & TMT',
                              children: [
                                _InfoRow(label: 'Pangkat / Golongan', value: d?.pangkatGolongan),
                                _InfoRow(label: 'TMT Kepangkatan', value: _formatDateString(d?.tmtKepangkatan)),
                                _InfoRow(label: 'TMT CPNS', value: _formatDateString(d?.tmtCpns)),
                                _InfoRow(label: 'TMT PNS', value: _formatDateString(d?.tmtPns)),
                                _InfoRow(label: 'TMT Jabatan (TMT Sistem)', value: _formatDateString(d?.tmt)),
                                _InfoRow(label: 'TMT Pangkat Berikutnya', value: _formatDateString(d?.tmtPangkatBerikutnya)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeSlideIn(
                            index: 3,
                            child: _SectionCard(
                              title: 'Sistem & Finansial',
                              children: [
                                _InfoRow(label: 'Status Portal Kepegawaian', value: d?.portalStatus),
                                _InfoRow(label: 'Status SIMPATIK', value: d?.simpatikStatus),
                                _InfoRow(
                                  label: 'Mendapat Tunkin',
                                  customValue: StatusBadge(
                                    label: (d?.mendapatTunkin ?? false) ? 'YA' : 'TIDAK',
                                    tone: (d?.mendapatTunkin ?? false) ? BadgeTone.success : BadgeTone.neutral,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeSlideIn(
                            index: 4,
                            child: _SectionCard(
                              title: 'Masa Kerja',
                              children: [
                                _InfoRow(label: 'Masa Kerja Keseluruhan', value: d?.masaKerjaKeseluruhan),
                                _InfoRow(label: 'Masa Kerja Golongan', value: d?.masaKerjaGolongan),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Tab 3: Dokumen & Lain-Lain
                  RefreshIndicator(
                    color: AppColors.red,
                    onRefresh: () async => provider.loadDetailPegawai(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        children: [
                          FadeSlideIn(
                            child: _SectionCard(
                              title: 'Data Lain-Lain',
                              children: [
                                _InfoRow(label: 'No. KTP (NIK)', value: d?.noKtp),
                                _InfoRow(label: 'No. Kartu Keluarga', value: d?.noKartuKeluarga),
                                _InfoRow(label: 'BKN PNS ID', value: d?.bknPnsId),
                                _InfoRow(label: 'Tinggi Badan', value: d?.tinggiBadan != null ? '${d!.tinggiBadan} cm' : null),
                                _InfoRow(label: 'Berat Badan', value: d?.beratBadan != null ? '${d!.beratBadan} kg' : null),
                                _InfoRow(label: 'Jenis Rambut', value: d?.jenisRambut),
                                _InfoRow(label: 'Bentuk Muka', value: d?.bentukMuka),
                                _InfoRow(label: 'Warna Kulit', value: d?.warnaKulit),
                                _InfoRow(label: 'Ciri Khas', value: d?.ciriKhas),
                                _InfoRow(label: 'Cacat Tubuh', value: d?.cacatTubuh),
                                _InfoRow(label: 'Hobi', value: d?.hobi),
                                _InfoRow(label: 'No. Karis / Karsu', value: d?.noKarisKarsu),
                                _InfoRow(label: 'No. BPJS Kesehatan', value: d?.noBpjsKesehatan),
                                _InfoRow(label: 'No. BPJS Ketenagakerjaan', value: d?.noBpjsKetenagakerjaan),
                                _InfoRow(label: 'No. Taspen', value: d?.noTaspen),
                                _InfoRow(label: 'No. NPWP', value: d?.noNpwp),
                                _InfoRow(label: 'No. Kartu ASN Virtual', value: d?.noKartuAsnVirtual),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeSlideIn(
                            index: 1,
                            child: _SectionCard(
                              title: 'Berkas Dokumen Digital',
                              children: [
                                _DocumentCard(
                                  title: 'Foto Profil',
                                  url: d?.fotoUrl,
                                  onTap: () => _openDocument(context, d?.fotoUrl, 'Foto Profil'),
                                ),
                                const SizedBox(height: 12),
                                _DocumentCard(
                                  title: 'Arsip KTP (NIK)',
                                  url: d?.fileKtpUrl,
                                  onTap: () => _openDocument(context, d?.fileKtpUrl, 'KTP'),
                                ),
                                const SizedBox(height: 12),
                                _DocumentCard(
                                  title: 'Arsip SK Kepegawaian',
                                  url: d?.fileSkUrl,
                                  onTap: () => _openDocument(context, d?.fileSkUrl, 'SK Kepegawaian'),
                                ),
                                const SizedBox(height: 12),
                                _DocumentCard(
                                  title: 'Arsip Kartu Keluarga',
                                  url: d?.fileKartuKeluargaUrl,
                                  onTap: () => _openDocument(context, d?.fileKartuKeluargaUrl, 'Kartu Keluarga'),
                                ),
                                const SizedBox(height: 12),
                                _DocumentCard(
                                  title: 'Arsip Karis / Karsu',
                                  url: d?.fileKarisKarsuUrl,
                                  onTap: () => _openDocument(context, d?.fileKarisKarsuUrl, 'Karis / Karsu'),
                                ),
                                const SizedBox(height: 12),
                                _DocumentCard(
                                  title: 'Arsip BPJS Kesehatan',
                                  url: d?.fileBpjsKesehatanUrl,
                                  onTap: () => _openDocument(context, d?.fileBpjsKesehatanUrl, 'BPJS Kesehatan'),
                                ),
                                const SizedBox(height: 12),
                                _DocumentCard(
                                  title: 'Arsip BPJS Ketenagakerjaan',
                                  url: d?.fileBpjsKetenagakerjaanUrl,
                                  onTap: () => _openDocument(context, d?.fileBpjsKetenagakerjaanUrl, 'BPJS Ketenagakerjaan'),
                                ),
                                const SizedBox(height: 12),
                                _DocumentCard(
                                  title: 'Arsip Taspen',
                                  url: d?.fileTaspenUrl,
                                  onTap: () => _openDocument(context, d?.fileTaspenUrl, 'Taspen'),
                                ),
                                const SizedBox(height: 12),
                                _DocumentCard(
                                  title: 'Arsip NPWP',
                                  url: d?.fileNpwpUrl,
                                  onTap: () => _openDocument(context, d?.fileNpwpUrl, 'NPWP'),
                                ),
                                const SizedBox(height: 12),
                                _DocumentCard(
                                  title: 'Arsip Kartu ASN Virtual',
                                  url: d?.fileKartuAsnVirtualUrl,
                                  onTap: () => _openDocument(context, d?.fileKartuAsnVirtualUrl, 'Kartu ASN Virtual'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
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

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.red),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            separatorBuilder: (_, __) => Divider(color: AppColors.border.withOpacity(0.5), height: 16),
            itemBuilder: (_, index) => children[index],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? customValue;

  const _InfoRow({
    required this.label,
    this.value,
    this.customValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: AppColors.gray, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          customValue ??
              Text(
                (value == null || value!.isEmpty) ? '—' : value!,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final String title;
  final String? url;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.title,
    this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = url != null && url!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: hasFile ? AppColors.redSoft : AppColors.grayLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_rounded,
              color: hasFile ? AppColors.red : AppColors.grayLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.black),
                ),
                const SizedBox(height: 3),
                Text(
                  hasFile ? 'Berkas digital tersedia' : 'Berkas belum diunggah',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: hasFile ? AppColors.success : AppColors.gray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: hasFile ? onTap : null,
            icon: Icon(
              Icons.open_in_new_rounded,
              color: hasFile ? AppColors.red : AppColors.grayLight,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: hasFile ? AppColors.redSoft : Colors.transparent,
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerLoading extends StatelessWidget {
  const _ShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 100, height: 16),
                const SizedBox(height: 16),
                ...List.generate(4, (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: 80, height: 10),
                      SizedBox(height: 6),
                      ShimmerBox(width: 160, height: 14),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
