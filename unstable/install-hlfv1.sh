ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.9.3
docker tag hyperledger/composer-playground:0.9.3 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ڿjY �=�r۸����sfy*{N���aj0Lj�LFI��匧��(Y�.�n����P$ѢH/�����W��>������V� ES[�/Jf����4���h4@K�{��z��-2Ti�1uGk�G}��� � �����b�x&����Q��&�x�	���� �@��
�eK& OlS(��x���0�����.��)ʂ�@���KQ x<a���_�-)4�4�w�\����J�h��Ձfd�`)�j�m�U�;�����MҠ6PL]�C�#����rU���˥l>�~�2 ����n���vZ�4(ۨS���VTH�����������4��p�u�@����G���=�,�T�Fܿ �%E��3��l���<`g�{pԐԪ��+�����H�{ل-4���Zs�P�PwlTA�afru�M�(��T�	R�1ULL�4��H�+�R�P!�i7��=S�j*��-rWBEjwm�4�۷�|c��[��b�Ҝ����k��_��:�a���L}>�Sf��W3�p�Q6���z�l\3��Y�!��b�e�.1g�M�W�`ȕD�Q'��
�R�V���٩���1�o&����A{��=��<%��xaCS�Ա&��|g.��u�}��PBX�#V�<xx�O$�������rh���|�	���9����s�߆��҇��@���}� ���<�,���g������'b1nc���}i*Z�)Y]��S��~��-򧥘X��SBu��Z�W��;��^����1l�_�3U��z���7��<�#�X��t~R����_l��ˆ9�oHrm��疮=H������"�@�?�C* ���Xt����F�߿�2�bў��0a&̻�Ӿ��U�f[xdm0�����@�Z��ں��]��v� �Ӳ��x��`��@�1���@�$9vW7��*.���P�H���]�܌��^�z�M�T]��]	���$]�Uw��{�^G��m���"�����_�d馣���d�]e@p鎣 ���	�]>��$a�_��l;�����h8o�Ij�s��Yl8�{��,4�^Nr*g\�o�u�Q�_*ܲ�T5C���\`�q����3(�Ck���뀠�G=��mG#Nq`w%�U%�ڄ}} Q"��i�ֹ�(`Q~!�֍/��u��=�",�~}I)m�[��,� ��4>��UjHA��� ���P���� |��"�a#����e�@�$5Sm5�M6.[�nl��;9n~�f�> �P�{�G1��5����UᏘ�B���h���q[L�[�6�Lq�`��,Z�q�]���>1/4��Hd��GҞo�%��ʂ8�� ]SGd@��ss�'1�9�\�;ޱ�ָ�^uQTݑ�ؤ�����#���š��=�P���U(�`�U�.Љe~4����^��2ؐ�F��7�4n�~Iy�4�hxڼ
���6N��5��s��;��xI��5 MJ�ׯ��Z�ݡy=[������b{�Вd��kp���0g�ǌ�`�����������l�#��s�@m,�6�%���������v��֙�� �d�Ӧ6�L]�)l��L��i�i���@֏n��L��wuB���ճj��?����&�c�y�]��l?�@���$c9t��ܬ����g�R͗K�.���f��@ �͂���H��>n���A�8r	L��t(�Z��:Q�x+��|2�w*��VkB�vV��r�v3�h�hgy�h�Z�˙.L��cy��.4���_�1��W�IT"�;��x>�὿��&> KB��I�%d�K@s�Mh������,,.��dAG�t�V�d���舧�<g]��f�BOr��,bs���v6��ȸ��+��l�������a��O2�� .��(�L�	>���u���?��V�3��EC�� 2L�V.�xG�z+�F�������t�6V��L0	n��X<�x�Ä����E�ߛ����p|l3������a���?�O��(�o�?k���"ޅ�ڃ���i���0��>����ֲ�ށ���v�O�� Tm������{��$�M�kdٰp���5q����5"��t�����JL���"�h��*�4������Ų�?w�=�_���j`|
�2� d��߃G�|��W���x�"?�-w}�!�������������t���\�=r��?t�h[r%V�H � �v�z�t�ث'<�={�?��BL�3�R���ݎ�R{����������\tJ���&�k=�����v��<�q���E2E1�o��Ƃ���g��|����:��3/b��C�1�|h�7b��������Dg��e7���w���w��<����� ��SI�{ȶ !cE(Y��O?��?�J�5
94Gy'w���O��!y���Q��ڙ��C�eI���k�\r�(����4o���q���y�q�\�n�;�R�ѱ��5�=1e��E�6�{0�ɢL���И��̃k��Gc�JhB�y��9�#d�[�&�/(^�a�ϴ��l�?6��?	6���� O!�_r3�/���;�B`k*����K��qL�s�.Z�)�R�4�gi�L@��%!U3{��' ��`n'k�y1䮩�@
K4e0��)\0%J4��<�C ]��g��X92��X�
�Z9#��t��DkQO2��|���h���dFLG��(l�?�"�r.�/��
bC,�e�T=7�p>��Fd&�� &��;Ą�fO�\��j؅�2�U1]��k'�xB�\(��`���T����?+bm�8<1��ʹc4k[U��?���3��!l[*��_�*@�[�=��gy��N��̛��y��ZhV���5,h��?���L|��o-�������z��WAr��c�`��� �j�P����k 6_o3;Ƿ��a���M���~�]�~�U@,����E�V,v{1O��b/'�콢���� �����D�7�����}.�[��aXnj��Q����u��������!/<Կ�xvQX�+�-a �#�D/����Գ%�`D�\��/�!rU���؉[B�t��X��kn\�Ԝ��O����\
���g���繸��7����������װ��Edi5tj��Jx��֊���Vs�̝�Y��ϥ�������o=�����䖪���ڠ���ƗG-m��|	F���}/�o�'���Y�����G��a�(�5�Ѝ�� OC�@>@��I��o�#�.E����P�7z�(w�R��'�c��g���}0�g����k.ޫ+ӯ�L�;��A>�r���|De�m��Ϧ̍����y#e*�"��H��w	�X���M���!�^��C�[�@�M����^���m���g,����V��k%檧�}���E��|l��������� �?_Sgԇo���������#����_`��ȱ��iˬ�ƒR�َ�;�d��Lr1.!�c�X����d)��I������o��W��~EMW����7�O�a�
�_�!��t�O���m�ɷ�)*�k�nڊ���׭��Ƌ�u�������d5�o�������y;�����?�[��������Tl��[�z�2��O�y�o��y	?x5,G䧞�au�'�Jm�����F���8��s|˴�@�s���������,���J��;����8��GZj���"��(j(_���U��ÞN�w?Җ��޸<���#�²1Ij20o�9�ev�;Iؖc�9�0����Ȉ-d��IH�&����C��P��>�2D���� ܝ���˗@Z����|Z��$��V��ӹ�tZ��a�O	�|E(9e�Qz5jER���6��bO=�;'��4yΈw(_�T���	l]Lu��F�x!^
�T��@U�ҽR��S���G:/��B�͓k��SR�����:'�zy��\�j�[C������RtN�v�ͷ)�ʟ79�b?#H.N�&r��{�П�9��ʥbM���\��gʵ<w���I3N{�����#k�>:�4��r��M�~)֊h�p�ҩ������Ӂ�獓�x\L�=�(��ku.������1.�-�7/�v1�a8<>:���1/��ЊU^���-�.�B�4h�R�h$S�\j�k�Z�%���K���Cq_`�B*��\���\�Z+6�� Qz����v<���R{���
��FB���'ҁp��ZUEዉ�ĩ1�씪��UlV�1q���k�T�(��\ j[�������w2B��~���;�p.Ŵ�{���z��O��S�I���{ͬzÃ��FI@^*�M&�������)
��34�i��E����c��Q���;�6k'0�#]&��d����Jd�<�j��a#9H�"�|����~�ͨ�guѐ����L8����Fq�Pb�Q:�LZ�zE�{��K�9b@_]]�#��/]����Z����Sֽʷ��3�'��H�L�X���n߆�(�7
w\�﫻C�E�O���i�������,�o��v�a%�@�8OH�S�����5Y�m�N嘡�m����䇅B�@W"I�׌?�N�B���oa)w��5���e��H�.2�҂P1i�^��z�2+��.�~Z�_5a�)k�꣣
?�*��}.�t��c���N��AN��H��
���0U����S�_�f;��G���c��ͮ��f�_|���i~�o����ss������Z ���S�|:��g{Cqx��?��
�Gr�#�Rbh��L]�e�/�;N�bᛎ!��O)��=�{"����[���$��.��=8(�.m��k��-X���I�Z���2Bgo/��OS��G��w���a�8���t�#i�k �<�>��G�����3�֍�I�'�"��i�������,P��/Za���<̼���C�/��@s�Z3!�Pmtٍ@*��!��mESHĔ��Q]��\����&u�5^�9�m=0Iz�����5�u�@I���@ d���h� _E��m\#]5�Lf�
!���(�&T�!	AªF�6���B��F���-[#�����3�Ks�m�C��������K��������f�G���� [Gkw�KW�K�P��*�������D$�B82�����^}�B현�� ��q������ĸr��$����o_^V��h��2yc��=�'��ݶ���g{<6�Q����q��q�ݶWO
W�E�ZXĉN��.H��Ю@	� G��TU���|��7q�yv���U���T���l���#|�L"E�X��6:\>��h� �`2T J���&�bB����*��P� �e$t�����G�����T�Ӌ'���ڏ~�F!��I�L��_��>Y(3c䌍�l2���9('��6]h�KЀ1�D���f>��>����,H��ϝ����I����w�{�5������ϟ�]�Ľ�XB�`�P�3�Oa{c�+���F�.�U�-�sr��c4�f��8��������3���N��L���4%��6�Bԉ 5$�:���G'�d�Ɩ�-r@�4[�$��%���3.�ޟ}���a�vO�
��И(�)�[k ��A�M���e}�2��:ppQKt����@q��ߖ��\dx��td=��a�6���-Vz�j���j�=!�gz�ȁo>�ʜ|��y�s����>,�&k2�Z�*��>~r���ej�o�D�"��KŇSk��JW��P����ځ���a�]~�Iwn2G�U�(*����eIY�eC��� ʰ�ʵ5��|��u�Dl�i�k6�t��й���n$�C2�'�TZ�*����s��G���9�p����S��w��W��E���.zf���Y�v����S�ps7:�I���2��<���Nĺz�O�c����?��>��|��]rz��O������O������0��{�'�s���W���?�~H�M�I�Ww^��ݷv�c��F;������X/������e%KF��ԋ%{�H:��d*)g HJ
��D"���0CB�)q9-uC���ד�������}��g�ο���`��G_��ߊߏ�~=����W�Z3�w����6�m�gC��p������|@|}��A�_������߿��h;b�@���)C0Vc�R��N7�-��)(	�i3,}Ĩ�ypV��j,}�,���-���W�UG`�N�P���c8 �� ��ܔ�NH+9;2//�p֞g��p�0m���4B(��.: ��H�ǢPl�i��c�ݚ�;��B�}�޶s4~V�lJ�M���Q�/��n�<�;gc�#n���w��q�ݢl)ߜ��K��v^�4,���g�Fb;�֪�Aڕ6æs�_�P.��å��u�-�������}�ɎuSW,:W)�Z���@"��\�<kP��L�כIH��rO�ElU��ҵB��a߫��@�1h��#��<����fmL,:�M�F�%=ƨ�Z��՚��~�29����H���!�)&�O�j���(�G�^|߄)�uȲN�jv19��3�iN,b�I��Vj&'��8�5�.�^��j�ϟ��f"	f�FӪ��Q�����X�[��?VD����������/����^�Mw�_wE_w_w�^w�^wE^w^w�]w�]wE]w]�0�W(�.�f�@GCo���d���*J�Eng�w;��D���lI%��ND�gG��n'��vV#p.���|I �s�C�D�о��!�﹝�I�X �|7�D��������~oYMNG�z>U���L��ߡ�1KKuZb�{��g9�ȴ
с,�Q3*�i휈h->�5A�S�u9S=�PQcl���%�w?��^���:���ҙx�&W�-O*QS�*�>[�T7%�I;֯�ۗ��]��3��r�LR��񄚰+&�d�ܨ�R3�"��i*1���I)E�X�\D._9:֒�N�2�V	9�cAo��e��tr�]�e��ެ��j�ַC���z�Qh'������v�F����/���v�ao��2�Ǿ f��pY4χ�ê�k�E���;;��x|w�]����&�r���޷�:�B;�.o����W�l�=B��I��x��7��{��?~s������~�A���(�Ϯ5e�%4e2X�|�J�*��1U��(s��IR�u/�| �l��c����M���9ǰ���@*�-q��Y��ӳ\�m���"�U�9�5]��i�O��Y�
2���@!JK�EF��΂gV�C`A2k1�jj̒�R�d6Y�g�U%wV#2�j�5;�3C�\Fx�]�׆�jG;�w�tv()]s���y'N��^ky2�U��*m'"]q�L�x�A۳H:�N�Q��N�t50"��i!,d�X�Y��1YH�r�1tX��f/��=�O�,�7Ρ�/�v�a�[4�,�#b�Q���2��ډ�TO�%����1��T|pR��IH�94�.�U�*�8b���3#�ו��lTj�g�x��z#<Y���x`�׮U�,
�%?P���a�ok´T�ҥ��N����?~���)0���K�rnI{2;,�=�H�Z��OX��	l{Q>�ev�(�L�4�O��ϸ����m��Sw��gtۭ��r��Ok���p"8�\c�3�2�V�j�T�WK�h;o���q���F�\
�ZZ�9VZ�܀�L��X�>�d(8�:��Uz�ֲg�p�L'��rY��-.\��ve�	��M�G���1ٚ���΅��֪q^��3U�M�S�����	]��2�s�X���W݀�5�O`z�=IW�|�X)Z�)��b#5+L���Cp��¼^�¨�O��� [�x.E����mq�L�#T$*fk	#]\֞�PL�W��DYD�d�r$By6��G'Zj*P�$�AL����j�a�iב�s^���]��6v&�m�`<gB���+�	��1ϙ�Q8�9"8�ޡ4��X�y�=ʎ�ͤިrD5q���\f��#�1�5�^+��uj^�r�}qL��4��p��JT9�7��q?ӗ��L#���y��:��([J�Yj��}�v>Z�@���Ȯ��Y�PK�)�y��
���
헴F���x1Q��S*!��H��d�Uz6$�z4�PFc�0��ݘ�#S0�l�Iέ�2���l\_��N��iTX��]�L~X[���C�p7��z'�3y���3E�`��y��#�Xݾ�az7�&�F���v�x�ƪuŴ&���,���
�h�W�SS\�������7MC7|�=��qm�����!����/�����۰��֣���4�pm��d���A>�g�{zertMv����/�O����k#��U��(�'\���)�7,�fhො�	�����{>9O��v-��43������t|�ץs��&��/��5翯?������Y�A����d����h�����s?�_�>~�\>��4��zJ�Z���s'אn�)w&aH
��c�e���{x�d��0�&90T,|��s"�7�UA�����ݝyH.�	k�k`��k�յin�*}��C�3�	�*�5�J]����r�l���?�f]�r�e�E�ה��9}��9�R��-��d����&������A�p A����ǸD�:�"�� z�{0
B>:�A�)��ฟ(8SjB�Lbt5�=��}�1{�@d�g~�����"95��hML�n:!I�";1�er�@����].?k�<u�%M-�`���Zc�X�$��3���>٢���	V�0���a��]��������uT�)�1� ��E�~�5�>�\��"Ӆnj�\�?��<변DA�'�M<l+6M�u!c`�ݦ��o�~!kc�g�:$�6�������9VF���C*0�1��G/�'ɭ� 
�m���@?$����2I�:U��_v'�/��H����F�ceS�ۛ�޽y�r�D�nߘ�m��ࣵ^@��z�T|į7�������@21L����/�[=�����t��=������//dp;�����%�o��r(sk��� >ĭ�\ 6o8������L���8\V�+��6�k}��3��D��l�j>	��	�l�3[����cd�*�o�DJ�!�]��(�d�80N���� -���2�0�3���f���E�=����� 8�S��D��Ϸ���^6�����1Hw�ĩ/"�'6:0��F7JJ��P�ȅRBy1����!5׹�Ug�������!�2�Q
sÚ�� ��s�cͣ�9)8y���!�k��p[��X�aS~6P{l����恐#��h	�y
};*�YXPȎ����J�
�po��:h��W&�a��UW;X�8�X�[p&M
L�vU}��-��^z�H�K���mA��q�� GX�["F�Á
�&�o��Z��l+y��]	$AE�#W"GHO%3c������x\cRr��=�PV�({3��\�C��&��!���c��3MES�6��0�DW�"�9���*h��S-d	�)�JKC>A��]����h��3��6&�n�G�/�8n���{5� �q�"�ɶ�}uv��7��W������Ĺ��k��'R�����x���������z+ħ�O	��D%[��pl%�h��&w�!���g��:G3u>{��O����o���-\����oe��R[��r�Wg9�t��W��u�Oщ�c嚂������Q�b��@J�2Q$bJ,�K&{ݮң�T� *�����,��^&	���IpjK��^`w��bŹg�������O>풟n��	yɧ0� 5_r�Vl�_`ρ�x1�TH��$)OGR2����F@ �L�3J*�N���dt��AI�3J<�P 	(��\ t���m��)��nC% ���O�� |x�ָ]��bv�l��6�!ᶉ���[�Q٭�^���:����se�N�NK�|�;�J�dE������+�,[��g_E.�F�6�����
�/�_C�]����K��]Ѩ,]U�}X ���uu�
Cs�v��y|8';���L�[a�@+kas���՟Jx0]�u����آ�h�����lgl_�����^p�λ(*�e "\,uSB���K$���)����w�^:ೕ:�Fy�/�O�W���y�@��l�]Q:J�rL3�Nz,�re�Z����H���a��:<��d:rë38@qNT�)�W. i=u�D�xui�nl%{�*1[)���i�[��� [��ӣ����B�t�Y��HS�UZ,\TTa_[V���y��!�"��ei�f��,�nCe�+賕f��2n����+kN[k�������í��>M� 	��^NiB̓~�lg0$v�xk'��pʇ���W��^��O�i�*'��o}B�X�|�I/����ջ�M�g�����0��"]F�]����r�������W�}��l���v����o�ܫ��}^�����G�:^F�_��f۾���-qa�����~�������i�w��r~�����v���x><��ʋ��.����~}��>���́�y���B����?(濠�;������\�o�?I�d`�Q෯�A�e���a�Q �o����&��>����i�el( P�������� ��)�9�_���<P����?>(�2|Z������R���?��#�π����V����_���3����q$��(p�"9Ĉ:sK�Q0b�0��PD*�y�GL�p�dS,���uw~n��3<u��`�|����������4�,��r5w˻چ(���M�fze$�]�iӸ}��u�i�g\)��?��A�Fzm��.��l�V��n�Ew2��#�Ce���:��t��:���R���T���\����?kw�x��C��8|<�?��=��b�ߒ�'��� �O�w���?
�����?=���������'��(P0�_ʴ���������?%��@�#��ĽA�=����������������JP����?Y���
�� �tN���G�p�X�?�N�'� �/�!�/�n���s7������Ch�!����O���^���K�/��j��5E����R-�ҩ�+����B�?CSY=�v/���{z?/�f�|s����x[�g�WƲj�~x[��S�'1�i�*�8��%�Ԩ�E�܌��r�{\�w7�uڠN�56\m=O�q&WZu�ߩ�f1>U*�ޡ6�>�v\��Fn������I�J�g���!Փ�黮��7«s�x��{�����r6�7��>��vZ���L�zbf�A�ܩ4i�����Y5�Bmxj4w�jT���x�wܬ#W���_|�u�fۆ���:a�L��:�-i���������6�B
�@��������/��(��"����D��o$ �'��'�*6����h�(���K'	����?��Â������G����� ��@��C�qx���{������@w��0�G<�h��I�wWݿ�����������1�Ͻ~�h�?뉗���횻J�0�F0����:7�M�ٛ��p��*b�l2u���R���m���z�4q�����*�`M�Nu��-���kXO|�ǲ)�׸^�	PMY�!�TQ��X���O���=�wο�cc��N�ډ&�$v�������������
[�b�\5�*����=0|�;JeVQz�y�TOꕌ�X��!�G��V=��������,�uG�Q��P �7��i���� ��?��Á��g������� '��F%�#��B��"N�V�HN�����@�0Ð��B�	B�	��c$& cf�:p��{��������OOM�1=L�U�\)[<��Rq�=I��B�J�>�M+�`�U������Y���x��]��$�����R�Ub8nz���ж��r5^,5H�����>�4��&��x�r�%�l��?����k�����š��?�éo��a����8`��P�S0������}1>!p�������v��ww��_�!q�����Z��Ys��˩�MCΉ���)�ӛ��{j�.O�:�|]Z[��Ϝ�cb�;�PUK������_in�)�R�J]����<�}[��[���k���OC�� `����?��o��p������ �_���_������@,�� �迳$�� /�?�t�	������YU��x�̓F��0�����������������Ym��3����� ķz����T��y8��*U�2�� ���؎ې˥f�b�Ւ��3o;"ڥJYi�s�YYNG�T�SH���k
���G%���~�m�C.yg�fo���-��s"��;���<~�������� �[QrS9�[%�+�Y|��Z�/��IҎ�꾧h�H��m=VN"1D����Z��HM5y�@�������R�{#��ԴJ(��7�NeS�UC�5��v����hW?�Ji8lԔ�d8Ҍ�X�ͦǮ�i�)O�i,�cg��U����be��~�1�b��*���n���x7��(���cA�����������t�G��p<�(�������G$��~�����?'��� ����?������O��$������� HV$�ȏ(:fCҗ|��yV�R�Ř��2�gh:��b���;?8��w�9���w��z�`7;k�.�^�&�I@�z�zЬ�[�{�-�]�\�X��t�`�N���qN��\-��G�65q_�;�r�(��d�o-���vk�?�xRvٹ��#�����KK��V�X��ݶHfQ�������b�����|<�_,�������!���4��Q ��o��P��h�ߏ�x�����E�?M�������|��p�	P��������P�E����o�~���v�e�*��R=��d����M�wx*��[����o����{j�/����e?������d~���T+�b�wu'6�MUg�k�Vͽ`&�F�e�6&��n]�-��~O�w���oȍ�9�	g
��sM��Hͨ��=V?V��1�v��)�U�r��=x�_ֶ�h�(�V[��	��HĶӜ��f�p���[�-�VxsB׹���۪�D6uW5l�M6O�z�	�Ø������x���bg�w�W�rb$��W�~�V����u#7%a���Yk��䨲���,�#c]��8迳ڃ���������ϭ�p����kA@��P�p�����4��!�C�7�C�7�����8���SH`	��?��Á����8 ��돐�X��w�i� �_���_��-���N�7	�>~�ߥ�_Z�����K��@��8�?M���?�����~�?lE���x����E�`�s����_8�Sw�?@�#�����p������$����5P����?0����� ����G�p�X�?�&�������ΐ����X�?wS����?�� ��{��? �?���?������+H��9D����s�?,���^����E�����$ �� ��(6������	0��$���� ����X��ý�=���w$�����9p�����8@�?��C��¿X�?���@�� �o�l��!�/ �n���3�����8�?E��`@���PR�R<
�@%�fb��x1�����O��/����ϲ��o�Qw�����)���7��c����4��S�_��#N�g�R%s����$���T�IY����Zr�t�AlU���~^����i�Kz7�Ȗ*˝�^Mm��Mwv���P:�؅:_��8!���=���U�1��jtu�����]�v��~(�5wwlj�./b��L�khw󥊾�����?�C��6�S�B����_q������0`�����9,�b|B��������C������+�ecMd��(Vk�vt�T��B��Q^�K�1��Ƴ��9s�Tf[�.�ݎ�h2�i�h0&	k���$>P���)�Ýl;��x�>T�M{cj�C��qN2c�m���X�,��^<������E����'�����O �_��U�������� �����h�"���;?������>/������E�)�U�Q��_:;��E%�O�����[�=h����O��:��ׁ�k<��u����ݰ\��3ióNm��F�D���Ĩ�Q�q{��L�<�I�~#�$�)?�O�Lڌ�Բ��f¯��iu}+5�����v���J_<��K�^��m���r��J�W��N��&�b�@���Z9IڱU��-�S����i��HX��R�u�m�@(���5��I3�G�
��������}�X�o��vR�ڜyy��A�PK��*Jf�I2�JֵW�wfV-ל������
���W�(�>���+�iR�x����@��/|��?�����v��`�� ���b��B�7|��ut�/l�b���Y�"��Q ��I�����G4����	������Cx��;�?�?x)�guUU��_�?Lk�����Dؙ��4��Ϙ7'py��n���&;O�*���t�W2n��W=��Ή���0��5�G�u��Sʏ���s=y<�ͳ�K�T���e璺�d./�%ķ�%���U��1�j(_����䗂:��dl�6�u)��N['�\c�_��V�������O�{�v���O������2�dM��箻ꍫ��$��B<��+J�]��pD+^Sy��?|:Ν��5W��~�Y���Sڏ���{~ɮ�M�zODZbOU�氻aJ��Y�r?�:�2����\���4���%f>kֺϲ̉U�5E�'
=nNQ�����aGqQ�/{]y0�my� �9����)%F�Lܲ���aH��E��
����e�����%���[�ߛ�{�������_D@����#�b�@�K�҈	)��2ˇ҈di��G�P`i�3B��\HƁD�1Rtvp��o��������w��k|2�k^�3ړ`���E�a/ho��.�����{J�X�+W�U+�[��E�@��k����%�����������G	̭��� x�!�1P����?������/����K�����32q�����.t|4
o�~m�/�+�uz�]s�����K����%�G�"�70�)��z��=������lf�95[9Q�������+mV۲��v���×�A���@@p����@&D@Q+�7\��7S�2++/P�^�D8�:k���:<���~�W}�F��项��x��b�6o��-����,�j��R$V��y把�Ⱦ2I���o���!w��TM8�Ǣ�ÎM��O���v����T��í=e����6���~�33N��L��=v�	���C�g�$D�0JC����:�L��ֺ�uGm�3lrc��5�W
��r{3D�������"�?�^���f��J�uR7�j�*f� �?�N^Q�a��F��ZU�X�GOt���S�J�T���*0����������g�7�o��9�'6hחp�-Rj��!ǚ076���V������4�7���ߗ-�jA�U�����⭟��������,P����[�����Y<�jZ�+<����y�?�凌��b�A�AV����?�M����g�/������a���\Aey����VK���������w��9�����|�G��N��>�ݎ}5Q@>Lq�>*����Y	�N}}�l��6����a[<Y	����SWי+�y��;���0��t��K_gᅼ�y8+��j��T�EK��Z=b.��}g���=ohtZhy=u�cߘ��u�D�Aˈ��]�p�Vw}��zU�_��E����]���;^�f�����e�G�Ͳq�2���~,oYk������H�ǃ�1�efj�/�u!��N�X���o����	}�f�꾩Ϫ=CZL�1]��K_P��AA��)Ǯ�[���q0�k�GdUjH�o8������H�l|�`8F��>��*�پ�/�����7��d�,�]�࿨�����_���Y�?$����o�?�3�B�'�B�'����{����� 
	��[���a�??d��`W0"���Kv��& �7��7��w�o��_V���.��,��?����٠�������gFȆ�o���G(�������;��0��	���t\0�{ �����~���?e�<�|!��?���O�Y�������	Y����H�@�G& �� ���E!�vg��?2A���B������
�������E������o����L ��� ��� ��������? �l�W�����P�_��P�����!������ ��� ���������L�����s�����
���������H�����!�?7@�?��C�����a�''����)����~�����_��������CF(��4���U�%��5�`�f���MuiV��a0U�IZ7M��&{(��jS�1�z��O��G��B������^����<I¢RS�_���Z���w�I�6YK��x��u,48	��tl�߷h����_���i�ϑ@��*���SS��5���n��l:]=j{f�C'e>.en7����R�]���o,;��@U�����~����=NZx����|֪��InvG�5V��c�wsSy7x�P���?�C^���Y�"��?�����?�!O��|�S��
��"�?���{��j�	i/z��q3�r\Ӎ`w,k3���>W{k>��Ma��.;�����`;�v��ⳑK��I�#�6��x��N�����9^**'R�S$����2��%��m�z.x������+0�����u�I~�F���_P����꿠��`��_N�?�sD!�E��
�/|���Y�u?�nǊ���:0�G�!c�p�O�w�����-$����g:�[|>؆�mc1������Oa�.���n�SU�,��7+3U�8N�33��wL��K�\���D�m���kb�ص7�ү�}u_���cУ��J�s�6K^��%�?�*Ed[g��Zn8._�p� r}��\��9�?n��{�}ւ�K�'�/@.onJ�u���|�%�J�ɉ�YG`q�|�8���񾤋�Y#T�[l���9����8�F��b�T�8`��b�ΰ]�hwBj��H�qW�0��8����k��(���)��o��� �E���������
��B��ۣ��ܩ�b���@f������	���?o�'��O1�ȕ��"�������;��w�`�'����ϻ-������?y'��3A��\ �GV�����' �#��#�?������3��/��`�\��c�B�?���
����c.(D�O���bP��	�X�qN�?ԏ�rT=tG�����#0��4���u�m��������z��H+�o��]?�~����ڏ������Y�_k�׺����uu���}fO�R��=C\���#����❮��ڼQv\��p��N���z�Kqt\�lX5��+*�#��$-�E����Z��ܩ�U5��:�Z;6�2?)3L�J�+[�S}.������3�D������8�{3I�G��u'862f��uy~ga���Cw=�u�����u7>��&�ڜg���(/^k*����f�'��׏3`P����!w��j�����c�B�?���"���K������a0��	����������I���	�뿏����	��[���)�?'��� o�B���������i��+�Ge7�6vĎO�N��5j��?���h}���8����D砻���NN�2�?�@^��PP=�;�v8d�k��ݬ�uUGif�(����eu�!ܕ�T�F�"rt�V��I���]��(���F���;~��j2֚п_��E � I� ��`�񀕭isS�k���q�=ԣ��6$�S�厙�D���������e�
knG��Fd��T���Q;	C��f��~'�l�������_��+��>,�wK<& �l�W���w�+��Y�8�O�HFW+�iҪ�֪���`aR�F�N&A`՚Aẉ�f��nhmԪ�����[�~d����	����{��9b��!��֚/|�L$�<�;*����l1�*�Z4�Q�|]��T>mg�<Xe�T!���F����liMɱ�[U�K�>W��:�{J�%Ἔ6�E<L3`�$ >��U?����_�"�����r���E��n�G����C!��rC����`���"�?���{��t���+Q�I
�.1���Iu��:ްӊ�џ�>;Qw���!�v�ю�}�N6[{�ܠ|���S
��P�P3�2a�1B���w�WZ��QW�t�c���lC��ƛМ=����kQ���&��J���o���]��sD!��+7@��A�����<�@�"�?�����	_��T�Y�G�ײu��z���el5��;̻I���뿗����� �.����½��h���2�0~Y1�3<m����mј�:x"�j���E��N4=�#ۭt�rml�)����P�xuQ���f�s��2Iu��q�����{�������c�����"�����{����ָ�W���5�*ȼ�����Dጥ)i_�Q.op|r[y��h֋����S!=���>�E�3�@��#N��v�4��/�<3�Ξ��h�����8ȗ��e�{h�����:�kQ˦�� 4'�bk����/�sr�W�5�o'�4���8�j{g�|��_�g��12���?A�
�?\�s��J�?#P#���s������餺	��m�D���{^����Q㗟{�:r9.:��{�[��%��ӽH)���	K����G�f��KO~_���'-���g�m����T|`$���qt|}R��1�Ŗ���z��eK1�7��>��S��{�B��}���p����'������?�����F������^�t�0*A��]�ǋJ�f�>1��-�'$4��;㐾G
T��FI����tC���	�˃_~��_%}YJ�Kvx�k$���a���;���b���O��������x��JΊ<��������9F�eB
��|�Pzg��~z���ݔ��������һez������J��ociA��H��m��	Is<]MN�5/��b;!�`�y�g�6	E���%'�F�SR�����Hn����ިA�I��Ռ�C�����w�oH�1�w�&Ww!����B{�{N���K�a��6��ׁ�����%�r�w�ҝ��������\��F�HG폍�^��Q��l��.)i�W7���]�K~b|w ��	��}{��Q��;���H��aJ|��?��􀟾�aV���>����,�E?=�OO��    �X�.��- � 