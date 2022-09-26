// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0;
pragma abicoder v2;

import "forge-std/Test.sol";
import "tornado-core/Mocks/MerkleTreeWithHistoryMock.sol";
import "../src/Rollup.sol";

contract RollupTest is Test {
    uint32 public constant LEVELS = 3;
    uint256 public constant N = 2**LEVELS;

    Rollup public rollup;
    MerkleTreeWithHistoryMock public stateTree;
    mapping(address => bool) public seen;

    function setUp() public {
        bytes
            memory bytecode = hex"38600c600039612b1b6000f3606460006000377c01000000000000000000000000000000000000000000000000000000006000510463f47d33b5146200003557fe5b7f30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f00000016004518160245181838180828009800909089082827f0fbe43c36a80e36d7c7c584d4f8f3759fb51f0d66065d8a227b688d12488c5d408839081808280098009098391089082827f9c48cd3e00a6195a253fc009e60f249456f802ff9baf6549210d201321efc1cc08839081808280098009098391089082827f27c0849dba2643077c13eb42ffb97663cdcecd669bf10f756be30bab71b86cf808839081808280098009098391089082827f2bf76744736132e5c68f7dfdd5b792681d415098554fd8280f00d11b172b80d208839081808280098009098391089082827f33133eb4a1a1ab45037c8bdf9adbb2999baf06f20a9c95180dc4ccdcbec5856808839081808280098009098391089082827f588bb66012356dbc9b059ef1d792b563d6c18624dddecc3fe4583fd3551e9b3008839081808280098009098391089082827f71bc3e244e1b92911fe7f53cf523e491fd6ff487d59337a1d92f92668c4f4c3608839081808280098009098391089082827fd1808e2b039fd010c489768f78d7499938ccc0858f3295151787cfe8b7e40be108839081808280098009098391089082827f76978af3ded437cf41b3faa40cd6bcfce94f27f4abcc3ed34be19abd2c4537d008839081808280098009098391089082827f0a9baee798a320b0ca5b1cf888386d1dc12c13b38e10225aa4e9f03069a099f508839081808280098009098391089082827fb79dbf6050a03b16c3ade8d77e11c767d2251af9cdbd6cdf9a8a0ee921b32c7908839081808280098009098391089082827fa74bbcf5067f067faec2cce4b98d130d7927456f5c5f6c00e0f5406a24eb8b1908839081808280098009098391089082827fab7ab080d4c4018bda6ecc8bd67468bc4619ba12f25b0da879a639c758c8855d08839081808280098009098391089082827fe6a5b797c2bba7e9a873b37f5c41adc47765e9be4a1f0e0650e6a24ad226876308839081808280098009098391089082827f6270ae87cf3d82cf9c0b5f428466c429d7b7cbe234cecff39969171af006016c08839081808280098009098391089082827f9951c9f6e76d636b52f7600d979ca9f3b643dfbe9551c83b31542830321b2a6608839081808280098009098391089082827f4119469e44229cc40c4ff555a2b6f6b39961088e741e3c20a3c9b47f130c555008839081808280098009098391089082827f5d795e02bbaf90ff1f384741e5f18f8b644a0080441315d0e5b3c8123452a0b008839081808280098009098391089082827f281e90a515e6409e9177b4f297f8049ce3d4c3659423c48b3fd64e83596ff10108839081808280098009098391089082827f424185c60a21e84970f7d32cacaa2725aa8a844caea7ed760d2b965af1bf3e7d08839081808280098009098391089082827fd96fcbc3960614ea887da609187a5dada2e1b829f23309a6375212cea1f25c0908839081808280098009098391089082827ffde84026d7c294300af18f7712fc3662f43387ae8cf7fdda1f9a810f4b24bcf208839081808280098009098391089082827f3a9d568575846aa6b8a890b3c237fd0447426db878e6e25333b8eb9b386195c108839081808280098009098391089082827f55a2aa32c84a4cae196dd4094b685dd11757470a3be094d98eea73f02452aa3608839081808280098009098391089082827fcbc9481380978d29ebc5b0a8d4481cd2ef654ee800907adb3d38dc2fd9265fab08839081808280098009098391089082827f24e53af71ef06bacb76d3294c11223911e9d177ff09b7009febc484add0beb7408839081808280098009098391089082827fdbd44e16108225766dac3e5fe7acbe9df519bbba97380e5e9437a90658f2139308839081808280098009098391089082827fc6f434863c79013bb2c202331e04bccea2251c1ff6f191dc2afa23e6f6d28e4e08839081808280098009098391089082827f3490eeb39a733c0e8062d87f981ae65a8fccf25c448f4455d27db3915351b06608839081808280098009098391089082827f30b89830ff7ade3558a5361a24869130ce1fcce97211602962e34859525dac4f08839081808280098009098391089082827f29bae21b579d080a75c1694da628d0ecfd83efc9c8468704f410300062f64ca908839081808280098009098391089082827fe326499de0476e719915dd1c661ef4550723d4aee9ee9af224edd208790fce4408839081808280098009098391089082827f8c45208b8baa6f473821415957088c0b7e72a465f460b09ece2d270aee2f184108839081808280098009098391089082827ffe2ad454f451348f26ce2cc7e7914aef3eb96e8f89a4619a1dc7d11f8401c35208839081808280098009098391089082827f0929db368ef2af2d29bca38845325b0b7a820a4889e44b5829bbe1ed47fd4d5208839081808280098009098391089082827f16531d424b0cbaf9abbf2d2acde698462ea4555bf32ccf1bbd26697e905066f608839081808280098009098391089082827ff5c30d247f045ff6d05cf0dd0a49c9823e7a24b0d751d3c721353b96f29d76f608839081808280098009098391089082827f6eb7a3614056c230c6f171370fdd9d1048bb00b2cdd1b2721d11bdda5023f48608839081808280098009098391089082827f0ee9c4621642a272f710908707557498d25a6fdd51866da5d9f0d205355a618908839081808280098009098391089082827f78ca1cb1c7f6c6894d1cf94f327b8763be173151b6b06f99dfc6a944bb5a72f008839081808280098009098391089082827f5d24d0b1b304d05311ce0f274b0d93746a4860ed5cdd8d4348de557ea7a5ee7a08839081808280098009098391089082827f77423dabd1a3cddc8691438fc5891e3fd49ac0f3e21aaf249791bfde1303d2f308839081808280098009098391089082827f0642e8800a48cc04c0168232c6f542396597a67cf395ad622d947e98bb68697a08839081808280098009098391089082827fc1e7d3cbbc4c35b7490647d8402e56d334336943bda91fe2d34ca9727c0e3df508839081808280098009098391089082827f8d6fb1730335204f38f85e408ac861e76f24349ab6ee0469c22e19350bb24fe108839081808280098009098391089082827f67d0faf5f0db32a1b60e13dc4914246b9edac7990fb4990b19aa86815586441a08839081808280098009098391089082827f2605b9b909ded1b04971eae979027c4e0de57f3b6a60d5ed58aba619c34749ce08839081808280098009098391089082827fd276890b2c205db85f000d1f5111ed8f177e279cae3e52862780f04e846228d008839081808280098009098391089082827f2ac5905f9450a21ef6905ed5951a91b3730e3a2e2d62b50bdeb810015d50376b08839081808280098009098391089082827f7a366839f0291ca54da674ac3f0e1e9aa8b687ba533926cb40268039e57b967a08839081808280098009098391089082827f67ab0f3466989c3dbbe209c37ec272ba83984ba6e445be6d472b63e3ca7270e308839081808280098009098391089082827f0e786007d0ce7e28a90e31d3263887d40c556dec88fcb8b56bc9e9c05ecc0c2908839081808280098009098391089082827f0b814ed99bd00eca389b0022663dbfddfbfa15e321c19abcf1eaf9556075fb6808839081808280098009098391089082827f65c0321ba26fcee4fdc35b4999b78ceb54dcaf9fec2e3bdea98e9f82925c093208839081808280098009098391089082827fab2d2a929601f9c3520e0b14aaa6ba9f1e79821a5b768919670a4ea970722bf408839081808280098009098391089082827fcdd2e0744d4af1a81918de69ec12128a5871367303ff83ed764771cbbdf6502308839081808280098009098391089082827f74527d0c0868f2ec628086b874fa66a7347d3d3b918d2e07a5f33e1067e8ac5808839081808280098009098391089082827f1c6bf6ac0314caead23e357bfcbbaa17d670672ae3a475f80934c716f10aca2508839081808280098009098391089082827f3c4007e286f8dc7efd5d0eeb0e95d7aa6589361d128a0cccb17b554c851a643208839081808280098009098391089082827fae468a86a5a7db7c763a053eb09ac1a02809ce095258c88101ee319e12b0697e08839081808280098009098391089082827f9333e3d052b7c77fcac1eb366f610f6f97852242b1317a87b80f3bbc5c8c2d1d08839081808280098009098391089082827f52ec1d675cf5353153f6b628414783ca6b7fc0fe01948ca206daad712296e39508839081808280098009098391089082827f13ceeeb301572b4991076750e11ea7e7fcbfee454d90dc1763989004a1894f9308839081808280098009098391089082827f8505737e7e94939a08d8cda10b6fbbbf879b2141ae7eabc30fcd22405135fe6408839081808280098009098391089082827f6127db7ac5200a212092b66ec2bfc63653f4dc8ac66c76008fef885258a258b508839081808280098009098391089082827f12692a7d808f44e31d628dbcfea377eb073fb918d7beb8136ea47f8cf094c88c08839081808280098009098391089082827f260e384b1268e3a347c91d6987fd280fa0a275541a7c5be34bf126af35c962e008839081808280098009098391089082827fd88c3b01966d90e713aee8d482ceaa6925311d2342e1a5aca4fcd2f44b6daddc08839081808280098009098391089082827fb87e868affd91b078a87fa75ac9332a6cf23587d94e20c3262db5e91f30bf04b08839081808280098009098391089082827fb5ba5f8acad1a950a3bbf2201055cd3ea27056c0c53f0c4c97f33cda8dbfe90908839081808280098009098391089082827f59ca814b49e00d7b3118c53a2986ded128584acd7428735e08ade6661c457f7508839081808280098009098391089082827f0fc4c0bea813a223fd510c07f7bbe337badd4bcf28649a0d378970c2a15b3aa508839081808280098009098391089082827f0053f1ea6dd60e7a6db09a00be77549ff3d4ee3737be7fb42052ae1321f667c308839081808280098009098391089082827feb937077bb10c8fe38716d4e38edc1f9e7b18c6414fef85fe7e9c5567baa4a0408839081808280098009098391089082827fbacb14c0f1508d828f7fd048d716b8044aec7f0fb48e85e717bf532db972520708839081808280098009098391089082827f4ca0abb8beb7cff572a0c1e6f58e080e1bb243d497a3e74538442a4555ad40be08839081808280098009098391089082827fda9eefd411e590d7e44592cce298af87b2c62aa3cc8bb137aa99ca8d4aa551b508839081808280098009098391089082827f153dae43cef763e7a2fc9846f09a2973b0ad9c35894c220699bcc2954501c6bd08839081808280098009098391089082827fd4ed2a09375813b4fb504c7a9ba13110bdd8549a47349db82c15a434c090e87b08839081808280098009098391089082827f0063a5c4c9c12dcf4bae72c69f3a225664469503d61d9eae5d9553bfb006095b08839081808280098009098391089082827fdc8a4d35ad28e59dd3713b45985cd3b70e37ccc2be42086f1ea078fe2dc9d82d08839081808280098009098391089082827f486ba219308f0c847b22fcb4449f8855192536c01b8057904e81c1c7814f483b08839081808280098009098391089082827f34d9604140a1ac9fdb204285b9fe1b303c281af2fc5fb362f6577282b423bcf308839081808280098009098391089082827fc1681959ec4bc3656911db2b2f56aa4db709c26f1a0a25c879286e37f437465d08839081808280098009098391089082827ffcd849f3b5f9e4368af75619fb27f2e335adbb9b44988f17c4d389fa751ad47a08839081808280098009098391089082827ff5f7fc22ad64c8e7c1e005110e13f4f1c6b1f8f8cc59000db0e3bb38f99554a508839081808280098009098391089082827fa9133b8a20fbae4633ec5f82cb47a38ae1877d12d1febb23982c7c808aa5317508839081808280098009098391089082827ff4827c5c7b61141cc31b75984bb3ed16ed579e5b72e32a1289b63ab55eaf8c1208839081808280098009098391089082827fcca361819ffefe3e50fe34c91a322c9405f4e5a168c1fc0a0a1883993e32c9f408839081808280098009098391089082827f6656088842bfc9e325a532784d3362cecfa86f9c7b208a6b499836ebe48ff15708839081808280098009098391089082827f00129c7cd00e42ed05a37dbceb80d47b65e1d750ef2148278a54723fdf42c4cc08839081808280098009098391089082827fa85b235631b786f85cd46f7768f6c71ae004ad267ae59bdf929ada149b19588808839081808280098009098391089082827f34df65a82686be09c5b237911abf237a9887c1a418f279ac79b446d7d311f5ea08839081808280098009098391089082827f815a850c3989df9ca6231e0bdd9916fc0e076f2c6c7f0f260a846d0179f9c32d08839081808280098009098391089082827f50fb0940848a67aee83d348421fadd79aefc7a2adabeec6e64904ebe1bf63e7d08839081808280098009098391089082827fbab63a16273599f8b66895461e62a19ff0d103693be771d93e3691bba89cdd8d08839081808280098009098391089082827f6931a091756e0bc709ebecfffba5038634c5b3d5d0c5876dd72aac67452db8a208839081808280098009098391089082827f55559b8bb79db8809c46ee627f1b5ce1d8e6d89bf94a9987a1407759d1ba896308839081808280098009098391089082827fa9a1a11b2979018cb155914d09f1df19b7ffec241e8b2487b6f6272a56a44a0a08839081808280098009098391089082827ff83293400e7bccea4bb86dcb0d5ca57fa2466e13a572d7d3531c6fa491cb0f1b08839081808280098009098391089082827fb7cb5742b6bc5339624d3568a33c21f31b877f8396972582028da999abf249f208839081808280098009098391089082827ff56efb400f8500b5c5bf811c65c86c7ed2e965f14f1a69bca436c0c60b79f46508839081808280098009098391089082827fd7c4427998d9c440f849dcd75b7157996eaad1b9a1d58cc2441931300e26eb2208839081808280098009098391089082827fca5ed18ad53e33fdc3ae8cf353ff3f6dd315f60060442b74f6b614b24ebd4cc308839081808280098009098391089082827f9ad3e9376c97b194a0fbf43e22a3616981d777365c765ead09a1d033fdf536b708839081808280098009098391089082827fc6daeff5769a06b26fe3b8fef30df07b1387373a7814cef364fe1d6059eaf54a08839081808280098009098391089082827fc20a78398345c6b8cf439643dab96223bf879c302648293eaf496fee5c978c6608839081808280098009098391089082827f589ca65b6cf0e90653c06dddc057dc61ba2839974569051c98b43e8618716efb08839081808280098009098391089082827f83064161f127d8c59fc73625957e21630dc6dc99e5443f6ce37ecd6bf28e69b708839081808280098009098391089082827f46d0ba662b50100b9a3af52052f68932feec1d12290b2033c4f49148893d8ba308839081808280098009098391089082827f18dd55b4a83a53f2ee578eb3e6d26f594824d44670fc3f4de80642344d15c09a08839081808280098009098391089082827f9fb5b594f48bc58b345ab90ded705920a7274b8e070eee8ce8cf90c72c3604b608839081808280098009098391089082827f1901d8f4f2c8449128e00663978f2050f2eb1cd6acb60d9d09c57c5d46ee54fe08839081808280098009098391089082827f5ec56789beab24ef7ee32f594d5fc561ec59dfeb93606dc7dcc6fe65133a7db408839081808280098009098391089082827f01c0b2cbe4fa9877a3d08eb67c510e8630da0a8beda94a6d9283e6f70d268bc508839081808280098009098391089082827f0b1d85acd9031a9107350eed946a25734e974799c5ba7cff13b15a5a623a25f008839081808280098009098391089082827f204497d1d359552905a2fe655f3d6f94926ea92d12cdaa6556ec26362f239f6408839081808280098009098391089082827fe075f7edc6631a8d7ffe33019f44fc91f286236d5a5f90f16de4791b72a2a5f008839081808280098009098391089082827f243f46e353354256ab8fe0ca4e9230dfc330bc163e602dfeaf307c1d1a7264b908839081808280098009098391089082827fd448ae5e09625fa1fcfd732fc9cd8f06e4c33b81f0a9240c83da56f41e9ecceb08839081808280098009098391089082827f2f312eef69a33d9fa753c08840275692a03432b3e6da67f9c59b9f9f4971cd5608839081808280098009098391089082827f5f333996af231bd5a293137da91801e191a6f24eb532ad1a7e6e9a2ad0efbc0008839081808280098009098391089082827fa8f771e0383a832dc8e2eaa8efabda300947acaf0684fabddf8b4abb0abd8a6208839081808280098009098391089082827f9ff0b3d7a4643596f651b70c1963cc4fa6c46018d78f05cb2c5f187e25df83a908839081808280098009098391089082827f9c373b704838325648273734dcdf962d7c156f431f70380ba4855832c4a238b808839081808280098009098391089082827fea2afa02604b8afeeb570f48a0e97a5e6bfe9613394b9a6b0026ecd6cec8c33a08839081808280098009098391089082827f68892258cd8eb43b71caa6d6837ec9959bfdfd72f25c9005ebaffc4011f8a7bf08839081808280098009098391089082827ff2824f561f6f82e3c1232836b0d268fa3b1b5489edd39a5fe1503bfc7ca91f4908839081808280098009098391089082827f164eda75fda2861f9d812f24e37ac938844fbe383c243b32b9f66ae2e76be71908839081808280098009098391089082827ff0a6fc431f5bf0dd1cca93b8b65b3f72c91f0693e2c74be9243b15abb31afcc008839081808280098009098391089082827fe68db66ba891ef0cd527f09ec6fff3ec0a269cf3d891a35ec13c902f70334b4f08839081808280098009098391089082827f3a44a5b102f7883a2b8630a3cae6e6db2e6e483bb7cfeb3492cbd91793ef598e08839081808280098009098391089082827f43939fe8ef789acb33cbf129ba8a3aa1bd61510a178022a05177c9c5a1c59bf108839081808280098009098391089082827f936fe3b66dfda1bc5a7aae241b4db442858bd720c1d579c0c869f273cd55d77408839081808280098009098391089082827f3490fcaa8ffa37f35dc67ae006e81352c7103945417b8e4b142afcaefa344b8508839081808280098009098391089082827fcae66096cff344caca53ffe0e58aafeb468bd174f00d8abc425b2099c088187408839081808280098009098391089082827fc7d05783a41bc14f3c9a45384b6d5e2547c5b6a224c8316910b208f2718a70ab08839081808280098009098391089082827f5ac6b9ba94040d5692b865b6677b60ef3201b5c2121699f70beb9f9b2528a02608839081808280098009098391089082827fa902a3d4d9ecbfb9b2c76fddf780554bf93cad97b244e805d3adb94e1816290008839081808280098009098391089082827fe9df91ffeeb086a4d26041c29dac6fca1d56a4d022fe34b38831267395b98d2708839081808280098009098391089082827f862646f851d91a8840ad9ee711f12ec13b3e8f980ff5ef5ee43ca4520d57def708839081808280098009098391089082827f30b7381c9725b9db07816baf8524943a79cea135807c84cce0833485c11e0c2e08839081808280098009098391089082827f96afc10c5cedaddbda99df79387397c9be74a5b50f3a0c04ccb68d4e0f3a989f08839081808280098009098391089082827f3543da80d10da251c548776fe907c4ef89993d62e0062ae5c0496fcb851c366108839081808280098009098391089082827fe5140fe26d8b008430fccd50a68e3e11c1163d63b6d8b7cc40bc6f3c1d0b1b0608839081808280098009098391089082827ffefdf1872e4475e8bbb0ef6fab7f561bff121314695c433bd4c29ec118060c9608839081808280098009098391089082827f6bb8c9f3d57b18e002df059db1e6a5d42ad566f153f18460774f68ac2650940008839081808280098009098391089082827f5415122d50b26f4fab5784004c56cf03f128f825ad2236f4b3d51f74737bd97308839081808280098009098391089082827f00e115c4a98efae6a3a5ecc873b0cef63ccd5b515710a3ab03ec52218f784dc908839081808280098009098391089082827fda7d525427bad87b88238657c21331245578bc76aa6240b7f972382537a202ab08839081808280098009098391089082827f83332e8b34505b83010270dc795290a2f515b8f89c163acecdf4799df04c62f808839081808280098009098391089082827fb09ecb6033d1a065f17a61066cd737d0c3c5873b51c3ab0a285e26939e62aa1808839081808280098009098391089082827f24e65c718938c2b937378e7435332174329730bde85a4185e37875824eb4985908839081808280098009098391089082827f68e41430ccd41cc5e92a9f9acd2e955c1385b9f5ed8d3f133d767429484a8eba08839081808280098009098391089082827fc038fe9d0125ab8be54545276f841274e414c596ed4c9eaa6919604603d1ffa908839081808280098009098391089082827f23248698612cd8e83234fcf5db9b6b225f4b0ba78d72ef13ea1edff5f0fb029808839081808280098009098391089082827fd2a9fa3d39c1ba91eefa666a1db71c6e0e4e3b707626b0197a4e59e7110cf0d408839081808280098009098391089082827fc28931ee7dfa02b62872e0d937ba3dc5c637118273a1f1f0c4fc880905c82efc08839081808280098009098391089082827f01cd399556445e3d7b201d6c5e56a5794e60be2cfd9a4643e7ead79bb4f60f7908839081808280098009098391089082827fac855cc58d5fbb0dff91a79683eb0e914c1b7d8d0a540d416838a89f83a8312f08839081808280098009098391089082827ff7798af7ccf36b836705849f7dd40328bf9346657255b431446ec75a6817181608839081808280098009098391089082827fe52a24c92d3f067bf551eeaf98c62ba525e84882d7adad835fad8de72986b2b108839081808280098009098391089082827fffc8682759a2bf1dd67c87a77c285467801f1c44fd78fa4eb5957a4832c9d72d08839081808280098009098391089082827f1482ac3e7e4f321627850d95a13942aea6d2923402b913046856ff7e8aaf9aff08839081808280098009098391089082827f17332b4c7aac2a07ccfe954de7ad22ccf6fcb4c5fa15c130ed22a40ae9398f4708839081808280098009098391089082827fd4be0546013f84a0d1e118b37589723b58e323983263616d1b036f8b3fdd858308839081808280098009098391089082827fa64ec737d31dddf939b184438ccdd3e1d3e667572857cd6c9c31a0d1d9b7b08508839081808280098009098391089082827f8ad12fbc74117cff4743d674539c86548c6758710a07a6abe3715e4b53526d3408839081808280098009098391089082827f15a16435a2300b27a337561401f06682ba85019aa0af61b264a1177d38b5c13c08839081808280098009098391089082827f22616f306e76352293a22ab6ee15509d9b108d4136b32fa7f9ed259793f392a108839081808280098009098391089082827f519727b25560caf00ce0d3f911bd4356f907160ab5186da10a629c7ccae1851e08839081808280098009098391089082827fcff39e77928ce9310118d50e29bc87e7f78b53ad51366359aa17f07902ae639208839081808280098009098391089082827f17dead3bfa1968c744118023dead77cdbee22c5b7c2414f5a6bdf82fd94cf3ad08839081808280098009098391089082827f2bef0f8b22a1cfb90100f4a552a9d02b772130123de8144a00c4d57497e1d7f408839081808280098009098391089082827fbf5188713fef90b31c35243f92cfa4331ab076e30e24b355c79b01f41d152a1108839081808280098009098391089082827f3baadd2fd92e3e12fb371be0578941dc0a108fbca0a7d81b88316fb94d6b4dfe08839081808280098009098391089082827fd4f955742e20a28d38611bf9fc4a478c97b673a7cd40d0113a58a1efe338d9aa08839081808280098009098391089082827f3c1c3fe9a5f7ccd54ad5a51a224b3f94775266d19c3733017e4920d7391ad64508839081808280098009098391089082827f6372df6148abeed66fda5461779a9651130c6c525df733852bcd929016768a7a08839081808280098009098391089082827f6d098e848fb853f95adb5a6364b5ab33c79fb08877f2cf3e0e160d9fcb3ebcc508839081808280098009098391089082827f48c5fc90f27431fabfe496dfba14bb0dba71141eb5472a365fd13023f4fe629608839081808280098009098391089082827fbb988dfc0c4dfe53999bd34840adcb63fdbf501ccd622ca2ddf5064ad8cdebf408839081808280098009098391089082827f25b068c942724c424ed5851c9575c22752c9bd25f91ebfa589de3d88ee7627f908839081808280098009098391089082827fed98a1931e361add218de11ff7879bd7114cda19c24ddbe15b3b0190ce01e1aa08839081808280098009098391089082827fc80b5a7d63f6c43542ad612023d3ffd6c684ce2eab837180addcb4decf51854408839081808280098009098391089082827fe2ef24bf47c5203118c6ff96657dd3c6fdff7212d5c798d826455de77b4b70cd08839081808280098009098391089082827f907da812fd5a8375587e4860f87691d0a8d61d454c507d09e5562e1a5d0fcc7608839081808280098009098391089082827fc459abbc62bc6070cacdff597e97990de56edc51cc6643afb0f6789fef1bad6308839081808280098009098391089082827f38d61f5e566855d70d36ef0f0f1fefcd7c829bdd60d95e0ef1fb5b98856280a408839081808280098009098391089082827f13218626665c420d3aa2b0fa49224a3dce8e08b8b56f8851bd9cb5e25cb3042d08839081808280098009098391089082827f6f685fb152dba21b4d02422e237e246df73d7d711ae6d7d33983bae0f873e31008839081808280098009098391089082827f5ade34719e2498dde70e4571c40474475a4af706a3cb82ac18a7fa44c22d1c4708839081808280098009098391089082827f8a0c3dc7a496adca059cb95d9b173812a00f3c4d435e0b9e8116e0c4b5f56acb08839081808280098009098391089082827f196bc98252f63169ed79073ee091a0e8ed0b5af51017da143940c00bdb86370908839081808280098009098391089082827fd979bf70695d93f8efb552a413701918afec9e12dfe213f4d0c27cfa68fad6c208839081808280098009098391089082827fb803072d02f54d237a3c6c4cc18eda6dce87a03c6819df54e4ed8aed6dc56d4608839081808280098009098391089082827f1efcda9d986cddcf431af4d59c6a7709d650885b7886cba70f0e7cd92b331cdc08839081808280098009098391089082827fd3ca5f7859b82ac50b63da06d43aa68a6b685f0a60397638bbea173b3f60419208839081808280098009098391089082827fa59d392c0667316ad37a06be2d51aabe9e79bdef0013bc109985648a14c7e41f08839081808280098009098391089082827fac2f5f0d2146791b396e2bed6cf15a20bc22cc4c8cf7dd4b3514ac00148dd0a708839081808280098009098391089082827f17a993a6af068d72bc36f0e814d29fef3f97d7a72aa963889b16a8457409861a08839081808280098009098391089082827f6f1bf99686550e0396f7f4e2df6fdaa090fbc272c8c76eb32a3c6791de5a07b508839081808280098009098391089082827f8234d705e1ecdc59cc6ed40749069d4b45e63deb49b5b7d7f527abd31c072b1b08839081808280098009098391089082827f6fe929a1fd6aacba5c4012c45dd727d2c816119567450003913d882cb97bc47e08839081808280098009098391089082827fad5371215f2aba49026b2e48739c11b4d8ffbb24dd4a6e41b9763862af96787a08839081808280098009098391089082827fd0e704566c49e1a11edc2c128b2e07f36dc0c755468268f8fe4c4859b9fa595b08839081808280098009098391089082827f263e1195090d00be1d8fb37de17ccf3b66d180645efa0d831865cfaa8797769e08839081808280098009098391089082827fe65c090eebde2cfa7f9c92cf75641c7683fb8e81f4a48f5b7a9c7eb26a85029f08839081808280098009098391089082827fa18971781c6855f6a9752912780bb9b719c14a677a4c6393d62d6e046b97a2ac08839081808280098009098391089082827ff6fc1ef1bca8bec055cc66edecc5dc99030fe78311a3f21d8cd624df4f89e62508839081808280098009098391089082827f824e4e2838501516d3296542cb47a59a1ca4326e947c9c874d88dccc8e37b99a08839081808280098009098391089082827f3cd5a9e7353a50e454c9c1381b556b543897cc89153c3e3749f2021d8237226308839081808280098009098391089082827fb4bcedbd54d0c917a315cc7ca785e3c5995abbeeb3deb3ebaf02c7a9bf6cc83f08839081808280098009098391089082827f1f7476211105b3039cef009c51155ae93526c53a74973ecfce40754b3df1052108839081808280098009098391089082827f58aefbd978440c94b4b9fbd36e00e6e36caeacf82b0da0a6161d34c541a5a6e308839081808280098009098391089082827fc22cd6d61be780a33c77677bc6ba40307b597ed981db57cb485313eec2a5a49708839081808280098009098391089082827fd9ffc4fe0dc5f835c8dcdc1e60b8f0b1637f32a809175371b94a057272b0748d08839081808280098009098391089082827ff6a5268541bc4c64ad0ade8f55dda3492604857a71c923662a214dd7e9c20c1008839081808280098009098391089082826000088390818082800980090983910860205260005260406000f3";

        address addr;
        assembly {
            addr := create(0, add(bytecode, 32), mload(bytecode))
        }

        rollup = new Rollup(LEVELS, addr);
        stateTree = new MerkleTreeWithHistoryMock(LEVELS, IHasher(addr));
    }

    function testDeposit(address[N] calldata senders, uint32[N] calldata values)
        public
    {
        bytes32 root = rollup.roots(0);
        assertEq(root, rollup.zeros(LEVELS - 1));

        for (uint256 i; i < N; i++) {
            vm.deal(senders[i], type(uint32).max);
            vm.prank(senders[i]);
            rollup.deposit{value: values[i]}();

            assertTrue(rollup.roots(i) != rollup.roots(i + 1));
        }
    }

    function arrayToString(uint256[] memory arr)
        public
        returns (string memory out)
    {
        out = "[";
        for (uint256 i; i < arr.length; i++) {
            out = string(
                abi.encodePacked(
                    out,
                    string(
                        abi.encodePacked(
                            '"',
                            vm.toString(arr[i]),
                            '"',
                            i == (arr.length - 1) ? "" : ","
                        )
                    )
                )
            );
        }
        out = string(abi.encodePacked(out, "]"));
    }

    function arrayToString(uint256[N] memory arr)
        public
        returns (string memory out)
    {
        out = "[";
        for (uint256 i; i < N; i++) {
            out = string(
                abi.encodePacked(
                    out,
                    string(
                        abi.encodePacked(
                            '"',
                            vm.toString(arr[i]),
                            '"',
                            i == (N - 1) ? "" : ","
                        )
                    )
                )
            );
        }
        out = string(abi.encodePacked(out, "]"));
    }

    function arrayToString(address[N] memory arr)
        public
        returns (string memory out)
    {
        uint256[N] memory arrUInt;
        for (uint256 i; i < N; i++) {
            arrUInt[i] = uint256(arr[i]);
        }
        return arrayToString(arrUInt);
    }

    function arrayToString(bytes32[] memory arr)
        public
        returns (string memory out)
    {
        out = "[";
        for (uint256 i; i < arr.length; i++) {
            out = string(
                abi.encodePacked(
                    out,
                    string(
                        abi.encodePacked(
                            '"',
                            vm.toString(uint256(arr[i])),
                            '"',
                            i == (arr.length - 1) ? "" : ","
                        )
                    )
                )
            );
        }
        out = string(abi.encodePacked(out, "]"));
    }

    function arrayToString(bytes32[][N] memory arr)
        public
        returns (string memory out)
    {
        out = "[";
        for (uint256 i; i < arr.length; i++) {
            out = string(
                abi.encodePacked(
                    out,
                    string(
                        abi.encodePacked(
                            arrayToString(arr[i]),
                            i == (arr.length - 1) ? "" : ","
                        )
                    )
                )
            );
        }
        out = string(abi.encodePacked(out, "]"));
    }

    function arrayToString(bool[] memory arr)
        public
        returns (string memory out)
    {
        uint256[] memory arrUInt = new uint256[](arr.length);
        for (uint256 i; i < arr.length; i++) {
            arrUInt[i] = arr[i] ? 1 : 0;
        }
        return arrayToString(arrUInt);
    }

    function arrayToString(bool[][N] memory arr)
        public
        returns (string memory out)
    {
        out = "[";
        for (uint256 i; i < arr.length; i++) {
            out = string(
                abi.encodePacked(
                    out,
                    string(
                        abi.encodePacked(
                            arrayToString(arr[i]),
                            i == (arr.length - 1) ? "" : ","
                        )
                    )
                )
            );
        }
        out = string(abi.encodePacked(out, "]"));
    }

    function testResolve(uint256[N] memory values) public {
        address[N] memory accounts;
        accounts[0] = 0xAC1c290d321Bb5E7c7FF7A31ED890CbbA9064FB0;
        accounts[1] = 0x71C7656EC7ab88b098defB751B7401B5f6d8976F;
        accounts[2] = 0xAbcD16DD77351f25D599a7Fbe6B77C2bAd643aE6;
        accounts[3] = 0x71C7656EC7ab88b098defB751B7401B5f6d8976F;

        values[4] = 0;
        values[5] = 0;
        values[6] = 0;
        values[7] = 0;
        for (uint256 i; i < N; i++) {
            vm.assume(values[i] < 10000000);
        }

        uint256[N] memory balances;
        for (uint256 i; i < N; i++) {
            if (!seen[accounts[i]]) {
                for (uint256 j; j < N; j++) {
                    if (accounts[i] == accounts[j]) {
                        balances[i] += values[j];
                    }
                }
            }
            seen[accounts[i]] = true;
        }

        for (uint256 i; i < N; i++) {
            stateTree.insert(
                stateTree.hashLeftRight(
                    stateTree.hasher(),
                    bytes32(uint256(accounts[i])),
                    bytes32(balances[i])
                )
            );
        }

        // Deposit into the rollup
        for (uint256 i; i < N; i++) {
            vm.deal(accounts[i], values[i]);
            vm.prank(accounts[i]);
            rollup.deposit{value: values[i]}();
            assertEq(accounts[i].balance, 0);
        }

        // Attempt to deposit too many times
        vm.expectRevert("Merkle tree is full. No more leaves can be added");
        rollup.deposit();

        // Attempt to withdraw before resolution
        for (uint256 i; i < N; i++) {
            bytes32[] memory pathElements = new bytes32[](LEVELS);
            bool[] memory pathIndices = new bool[](LEVELS);

            vm.expectRevert("The rollup has not been resolved");
            rollup.withdraw(
                accounts[i],
                balances[i],
                pathElements,
                pathIndices
            );
        }

        // Write to files for JS testing
        vm.writeFile(
            "input.json",
            string(
                abi.encodePacked(
                    '{"eventRoot":"',
                    vm.toString(uint256(rollup.getLastRoot())),
                    '","stateRoot":"',
                    vm.toString(uint256(stateTree.getLastRoot())),
                    '","eventAccounts":',
                    arrayToString(accounts),
                    ',"eventValues":',
                    arrayToString(values)
                )
            )
        );

        {
            bytes32[][N] memory pathElementss;
            bool[][N] memory pathIndicess;

            for (uint256 i; i < N; i++) {
                pathElementss[i] = new bytes32[](LEVELS);
                pathIndicess[i] = new bool[](LEVELS);

                {
                    uint256 index = i % 2 == 0 ? i + 1 : i - 1;

                    pathElementss[i][0] = stateTree.hashLeftRight(
                        stateTree.hasher(),
                        bytes32(uint256(accounts[index])),
                        bytes32(balances[index])
                    );
                }

                pathIndicess[i][0] = i % 2 == 1;

                for (uint32 levels = 1; levels < LEVELS; levels++) {
                    uint256 n = 2**levels;

                    MerkleTreeWithHistoryMock temp = new MerkleTreeWithHistoryMock(
                            levels,
                            stateTree.hasher()
                        );

                    for (uint256 j; j < n; j++) {
                        uint256 index = (levels == 1)
                            ? ((i < 4 ? 0 : 4) +
                                (i < 2 ? 2 : 0) +
                                (j == 0 ? 0 : 1))
                            : i < 4
                            ? 4
                            : j;

                        temp.insert(
                            stateTree.hashLeftRight(
                                stateTree.hasher(),
                                bytes32(uint256(accounts[index])),
                                bytes32(balances[index])
                            )
                        );
                    }

                    pathElementss[i][levels] = temp.getLastRoot();
                    pathIndicess[i][levels] = i >= n;
                }
            }

            vm.writeLine(
                "input.json",
                string(
                    abi.encodePacked(
                        ',"statePathElementss":',
                        arrayToString(pathElementss),
                        ',"statePathIndicess":',
                        arrayToString(pathIndicess)
                    )
                )
            );
        }

        {
            bytes32[][N] memory pathElementss;
            bool[][N] memory pathIndicess;

            for (uint256 i; i < N; i++) {
                pathElementss[i] = new bytes32[](LEVELS);
                pathIndicess[i] = new bool[](LEVELS);

                {
                    pathElementss[i][0] = stateTree.hashLeftRight(
                        stateTree.hasher(),
                        bytes32(uint256(accounts[i % 2 == 0 ? i + 1 : i - 1])),
                        bytes32(values[i % 2 == 0 ? i + 1 : i - 1])
                    );
                }

                pathIndicess[i][0] = i % 2 == 1;

                for (uint32 levels = 1; levels < LEVELS; levels++) {
                    MerkleTreeWithHistoryMock temp = new MerkleTreeWithHistoryMock(
                            levels,
                            stateTree.hasher()
                        );

                    for (uint256 j; j < 2**levels; j++) {
                        uint256 index = (levels == 1)
                            ? ((i < 4 ? 0 : 4) +
                                (i < 2 ? 2 : 0) +
                                (j == 0 ? 0 : 1))
                            : i < 4
                            ? 4
                            : j;
                        temp.insert(
                            stateTree.hashLeftRight(
                                stateTree.hasher(),
                                bytes32(uint256(accounts[index])),
                                bytes32(values[index])
                            )
                        );
                    }

                    pathElementss[i][levels] = temp.getLastRoot();
                    pathIndicess[i][levels] = i >= 2**levels;
                }
            }

            vm.writeLine(
                "input.json",
                string(
                    abi.encodePacked(
                        ',"eventPathElementss":',
                        arrayToString(pathElementss),
                        ',"eventPathIndicess":',
                        arrayToString(pathIndicess)
                    )
                )
            );
            vm.writeLine("input.json", string(abi.encodePacked("}")));
        }

        // Resolve the rollup
        {
            string[] memory inputsP = new string[](8);
            inputsP[0] = "snarkjs";
            inputsP[1] = "plonk";
            inputsP[2] = "fullprove";
            inputsP[3] = "input.json";
            inputsP[4] = "circuits/Rollup_js/Rollup.wasm";
            inputsP[5] = "circuits/Rollup.zkey";
            inputsP[6] = "proof.json";
            inputsP[7] = "public.json";
            vm.ffi(inputsP);

            string[] memory inputs = new string[](1);
            inputs[0] = "./prove.sh";
            bytes memory proof = vm.ffi(inputs);

            rollup.resolve(stateTree.getLastRoot(), proof);
        }

        // Attempt to deposit into the rollup after resolution
        for (uint256 i; i < N; i++) {
            vm.prank(accounts[i]);
            vm.expectRevert("The rollup has been resolved");
            rollup.deposit();
        }

        // Attempt to withdraw from the rollup without a valid merkle proof
        for (uint256 i; i < N; i++) {
            bytes32[] memory pathElements = new bytes32[](LEVELS);
            bool[] memory pathIndices = new bool[](LEVELS);

            vm.expectRevert("Provided root does not match result");
            rollup.withdraw(
                accounts[i],
                balances[i],
                pathElements,
                pathIndices
            );
        }

        // Attempt to withdraw from the rollup without a valid merkle proof
        for (uint256 i; i < N; i++) {
            bytes32[] memory pathElements = new bytes32[](LEVELS);
            bool[] memory pathIndices = new bool[](LEVELS);

            vm.expectRevert("Provided root does not match result");
            rollup.withdraw(
                accounts[i],
                balances[i],
                pathElements,
                pathIndices
            );
        }
        {
            bytes32[][N] memory pathElementss;
            bool[][N] memory pathIndicess;

            // Withdraw from the rollup
            for (uint256 i; i < N; i++) {
                pathElementss[i] = new bytes32[](LEVELS);
                pathIndicess[i] = new bool[](LEVELS);

                {
                    uint256 index = i % 2 == 0 ? i + 1 : i - 1;

                    pathElementss[i][0] = stateTree.hashLeftRight(
                        stateTree.hasher(),
                        bytes32(uint256(accounts[index])),
                        bytes32(balances[index])
                    );
                }

                pathIndicess[i][0] = i % 2 == 1;

                for (uint32 levels = 1; levels < LEVELS; levels++) {
                    uint256 n = 2**levels;

                    MerkleTreeWithHistoryMock temp = new MerkleTreeWithHistoryMock(
                            levels,
                            stateTree.hasher()
                        );

                    for (uint256 j; j < n; j++) {
                        uint256 index = (levels == 1)
                            ? ((i < 4 ? 0 : 4) +
                                (i < 2 ? 2 : 0) +
                                (j == 0 ? 0 : 1))
                            : i < 4
                            ? 4
                            : j;

                        temp.insert(
                            stateTree.hashLeftRight(
                                stateTree.hasher(),
                                bytes32(uint256(accounts[index])),
                                bytes32(balances[index])
                            )
                        );
                    }

                    pathElementss[i][levels] = temp.getLastRoot();
                    pathIndicess[i][levels] = i >= n;
                }

                vm.expectCall(accounts[i], "");
                rollup.withdraw(
                    accounts[i],
                    balances[i],
                    pathElementss[i],
                    pathIndicess[i]
                );
            }
        }
    }
}
