#!/usr/bin/env python
import glob
import Gnuplot as gp
from math import sqrt

codecs = dict(
          # bw,   name,          codec_type
    pcma = (64000,'G.711 A-law','itu'),
    pcmu = (64000,'G.711 u-law','itu'),
    g726_16 = (16000,'G.726 16kbps','itu'),
    g726_24 = (24000,'G.726 24kbps','itu'),
    g726_32 = (32000,'G.726 32kbps','itu'),
    g726_40 = (40000,'G.726 40kbps','itu'),
    g728 = (16000,'G.728','itu'),
    g729 = (8000,'G.729','itu'),
    g723_53 = (5300,'G.723.1 53kbps','itu'),
    g723_63 = (6300,'G.723.1 63kbps','itu'),
    amr_4750 = (4750,'AMR 4750','gsm'),
    amr_5150 = (5150,'AMR 5150','gsm'),
    amr_5900 = (5900,'AMR 5900','gsm'),
    amr_6700 = (6700,'AMR 6700','gsm'),
    amr_7400 = (7400,'AMR 7400','gsm'),
    amr_7950 = (7950,'AMR 7950','gsm'),
    amr_10200 = (10200,'AMR 10200','gsm'),
    amr_12200 = (12200,'AMR 12200','gsm'),
    speex_1 = (2150,'Speex 1','speex'),
    speex_8 = (3950,'Speex 8','speex'),
    speex_2 = (5950,'Speex 2','speex'),
    speex_3 = (8000,'Speex 3','speex'),
    speex_4 = (11000,'Speex 4','speex'),
    speex_5 = (15000,'Speex 5','speex'),
    speex_6 = (18200,'Speex 6','speex'),
    speex_7 = (24600,'Speex 7','speex'),

    speex_vbr_3000 = (3000, 'Speex VBR 3000', 'speex_vbr'),
    speex_vbr_4000 = (4000, 'Speex VBR 4000', 'speex_vbr'),
    speex_vbr_5000 = (5000, 'Speex VBR 5000', 'speex_vbr'),
    speex_vbr_7000 = (7000, 'Speex VBR 7000', 'speex_vbr'),
    speex_vbr_8000 = (8000, 'Speex VBR 8000', 'speex_vbr'),
    speex_vbr_10000 = (10000, 'Speex VBR 10000', 'speex_vbr'),
    speex_vbr_12000 = (12000, 'Speex VBR 12000', 'speex_vbr'),
    speex_vbr_15000 = (15000, 'Speex VBR 15000', 'speex_vbr'),
)
languages = """english""".split()


def filter_codecs(tp):
    ret = {}
    for k, v in codecs.items():
        if v[2] == tp:
            ret[k] = v
    return ret


def get_stat(data):
    """ Return mean value and std deviation based on values list"""
    data = list(data)
    avg = sum(data) / len(data)
    devdata = [ (avg-i)*(avg-i) for i in data]
    std = sqrt(
            sum(devdata) / ( len(data) - 1)
            )
    return avg, std


def get_mos(codec=None, language=None, gender=None):
    """
    Get PESQ MOS value list for given codec name, language and gender.
    """
    glob_list = 'output/%s/%s_%s.pesq' % (
            codec or '*',
            language or '*',
            gender and '%s*' % gender or '*')
    filenames = glob.glob(glob_list)
    for filename in filenames:
        fd = open(filename, 'r')
        yield float(fd.readline())
        fd.close()


def plot_speex(codec_type, language=None, gender=None):
    """
    Plot speex values on the top of `codec_type' codecs.
    Codec type must be one of "itu", "gsm".
    Language must be one of "languages".
    Gender must be one "male", "female".

    """
    g = gp.Gnuplot(debug=0)
    g('set terminal postscript eps enhanced color')
    g('set output "graphics/%s_%s_%s.eps"' % (
        language or 'all', gender or 'all', codec_type))
    g.title('Speex MOS values on the top of %s (%s, %s)' % (
        codec_type, language or 'all languages', gender or 'males and females'))
    #g('set size 1.5,1.5')
    g('set logscale x 2')
    g('set grid')
    g('set key right bottom')
    g.xlabel('Codec bitrate (kbit/s)')
    g.ylabel('MOS LQ')

    # plot speex
    spx = []
    for codec in filter_codecs('speex'):
        bw, name, _ = codecs[codec]
        bw = bw / 1024.0
        avg, std = get_stat(get_mos(codec, language=language, gender=gender))
        spx.append((bw, avg, std))
        spx.sort(key=lambda x: x[0])
        #g('set label "%s" at %.2f,%.2f rotate offset -1, -5;' % (
        #    name, bw, avg))
    spx_data = gp.Data(spx, with_='errorlines pt 5', title='Speex')

    # plot speex vbr
    spx_vbr = []
    for codec in filter_codecs('speex_vbr'):
        bw, name, _ = codecs[codec]
        bw = bw / 1024.0
        avg, std = get_stat(get_mos(codec, language=language, gender=gender))
        spx_vbr.append((bw, avg, std))
        spx_vbr.sort(key=lambda x: x[0])
    spx_vbr_data = gp.Data(spx_vbr, with_='errorlines pt 5', title='Speex VBR')

    # plot "background"
    bg = []
    for codec in filter_codecs(codec_type):
        bw, name, _ = codecs[codec]
        bw = bw / 1024.0
        avg, std = get_stat(get_mos(codec, language=language,
            gender=gender))
        bg.append((bw, avg, std*2))
        xoffset = {'pcmu': 1.5, 'g728': 1.5, 'g726_24': 1.5}.get(codec, -1.5)
        g('set label "%s" at %.2f,%.2f rotate offset %s, -1;' % (
            name, bw, avg, xoffset))
    bg_data = gp.Data(bg, with_='errorbar pt 5')

    ydata = [i[1] for i in spx] + [i[1] for i in bg] + [i[1] for i in spx_vbr]
    g('set yrange [%.2f:%.2f]' % (
            min(ydata)-0.5, max(ydata)+0.5
        ) )

    g.plot(spx_data, spx_vbr_data, bg_data)

if __name__ == "__main__":
    for language in languages:
        for bg in 'itu gsm'.split():
            plot_speex(bg, language=language)
    for gender in 'male female'.split():
        for bg in 'itu gsm'.split():
            plot_speex(bg, gender=gender)
